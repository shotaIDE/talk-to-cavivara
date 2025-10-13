import 'dart:async';

import 'package:characters/characters.dart';
import 'package:house_worker/data/model/chat_message.dart';
import 'package:house_worker/data/model/preference_key.dart';
import 'package:house_worker/data/model/send_message_exception.dart';
import 'package:house_worker/data/repository/last_talked_cavivara_id_repository.dart';
import 'package:house_worker/data/repository/received_chat_string_count_repository.dart';
import 'package:house_worker/data/repository/sent_chat_string_count_repository.dart';
import 'package:house_worker/data/service/ai_chat_service.dart';
import 'package:house_worker/data/service/cavivara_directory_service.dart';
import 'package:house_worker/data/service/preference_service.dart';
import 'package:house_worker/ui/feature/stats/cavivara_reward.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_presenter.g.dart';

/// 指定されたカヴィヴァラIDのチャットメッセージのリストを管理するプロバイダー
@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  List<ChatMessage> build(String cavivaraId) => [];

  /// ユーザーメッセージを追加し、AIからの返信を取得する
  /// [content] - 送信するメッセージ内容
  /// [cavivaraId] - 対象のカヴィヴァラID（このプロバイダーのパラメーターから自動取得）
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) {
      return;
    }

    // 簡単なID生成（DateTime + hashCode）
    final now = DateTime.now();
    final userMessageId = '${now.millisecondsSinceEpoch}_${content.hashCode}';

    final userMessage = ChatMessage(
      id: userMessageId,
      content: content,
      sender: const ChatMessageSender.user(),
      timestamp: now,
    );

    // ユーザーメッセージを追加
    state = [...state, userMessage];

    unawaited(
      ref
          .read(sentChatStringCountRepositoryProvider.notifier)
          .add(content.characters.length),
    );

    final aiChatService = ref.read(aiChatServiceProvider);

    // カヴィヴァラのプロフィールを取得してAI用プロンプトを使用
    final cavivaraProfile = ref.read(cavivaraByIdProvider(cavivaraId));
    final systemPrompt = cavivaraProfile.aiPrompt;

    // 現在のチャット履歴を取得（AIサービスに会話履歴として渡すため）
    final conversationHistory = state.where((msg) => !msg.isStreaming).toList();

    final aiMessageId = '${DateTime.now().millisecondsSinceEpoch}_ai';
    final thinkingMessage = ChatMessage(
      id: aiMessageId,
      content: '',
      sender: const ChatMessageSender.ai(),
      timestamp: DateTime.now(),
      isStreaming: true,
    );
    state = [...state, thinkingMessage];

    void updateAiMessage(ChatMessage Function(ChatMessage message) transform) {
      final currentMessages = state;
      final hasMessage = currentMessages.any(
        (message) => message.id == aiMessageId,
      );
      if (!hasMessage) {
        return;
      }

      state = [
        for (final message in currentMessages)
          if (message.id == aiMessageId) transform(message) else message,
      ];
    }

    var hasError = false;
    var buffer = '';
    try {
      final responseStream = aiChatService.sendMessageStream(
        content,
        systemPrompt: systemPrompt,
        conversationHistory: conversationHistory,
      );

      await for (final chunk in responseStream) {
        if (chunk.isEmpty) {
          continue;
        }

        if (buffer.isEmpty) {
          buffer = chunk;
        } else if (chunk.length >= buffer.length && chunk.startsWith(buffer)) {
          buffer = chunk;
        } else {
          buffer += chunk;
        }

        updateAiMessage(
          (message) => message.copyWith(
            content: buffer,
            timestamp: DateTime.now(),
          ),
        );
      }
    } on SendMessageException catch (e) {
      hasError = true;

      switch (e) {
        case SendMessageExceptionNoNetwork():
          updateAiMessage(
            (message) => message.copyWith(
              content: 'カヴィヴァラさんに声が届きませんでした。ネットワークの接続状況を確認してください。',
              sender: const ChatMessageSender.app(),
              timestamp: DateTime.now(),
              isStreaming: false,
            ),
          );

        case SendMessageExceptionUncategorized(message: final errorMessage):
          updateAiMessage(
            (message) => message.copyWith(
              content: '原因不明のエラーが発生しました。カヴィヴァラさんが疲れているのかもしれません: $errorMessage',
              sender: const ChatMessageSender.app(),
              timestamp: DateTime.now(),
              isStreaming: false,
            ),
          );
      }
    } on Exception catch (e) {
      hasError = true;
      // TODO(ide): ここは不要なはずなので削除を検討する。テストがパスしなくなる
      updateAiMessage(
        (message) => message.copyWith(
          content: 'エラーが発生しました: $e',
          sender: const ChatMessageSender.app(),
          timestamp: DateTime.now(),
          isStreaming: false,
        ),
      );
    }

    if (!hasError) {
      updateAiMessage(
        (message) => message.copyWith(
          isStreaming: false,
          timestamp: DateTime.now(),
        ),
      );

      if (buffer.isNotEmpty) {
        unawaited(
          ref
              .read(receivedChatStringCountRepositoryProvider.notifier)
              .add(buffer.characters.length),
        );
      }
    }
  }

  /// チャット履歴をクリアする
  void clearMessages() {
    state = [];

    // AIサービスのセッションキャッシュもクリア
    final cavivaraProfile = ref.read(cavivaraByIdProvider(cavivaraId));
    ref.read(aiChatServiceProvider).clearChatSession(cavivaraProfile.aiPrompt);
  }
}

/// 指定されたカヴィヴァラIDのチャット履歴をクリアするヘルパー関数
@riverpod
void clearChatMessages(Ref ref, String cavivaraId) {
  ref.read(chatMessagesProvider(cavivaraId).notifier).clearMessages();
}

/// 全てのチャット履歴をクリアするヘルパー関数
@riverpod
void clearAllChatMessages(Ref ref) {
  final directory = ref.read(cavivaraDirectoryProvider);
  final aiChatService = ref.read(aiChatServiceProvider);

  // 各カヴィヴァラのチャットをクリア
  for (final profile in directory) {
    ref.read(chatMessagesProvider(profile.id).notifier).clearMessages();
  }

  // AIサービスの全セッションをクリア
  aiChatService.clearAllChatSessions();
}

/// 最後に話したカヴィヴァラIDを更新する
@riverpod
Future<void> updateLastTalkedCavivaraId(Ref ref, String cavivaraId) async {
  final notifier = ref.read(lastTalkedCavivaraIdProvider.notifier);
  await notifier.updateId(cavivaraId);
}

/// 称号獲得通知の状態を管理するデータクラス
class RewardNotificationState {
  RewardNotificationState({
    required this.maxNotifiedThreshold,
    required this.hasEarnedPartTimer,
    required this.hasEarnedLeader,
    required this.isInitialized,
    this.unlockedReward,
  });

  final int maxNotifiedThreshold;
  final bool hasEarnedPartTimer;
  final bool hasEarnedLeader;
  final bool isInitialized;
  final CavivaraReward? unlockedReward;

  RewardNotificationState copyWith({
    int? maxNotifiedThreshold,
    bool? hasEarnedPartTimer,
    bool? hasEarnedLeader,
    bool? isInitialized,
    CavivaraReward? unlockedReward,
  }) {
    return RewardNotificationState(
      maxNotifiedThreshold: maxNotifiedThreshold ?? this.maxNotifiedThreshold,
      hasEarnedPartTimer: hasEarnedPartTimer ?? this.hasEarnedPartTimer,
      hasEarnedLeader: hasEarnedLeader ?? this.hasEarnedLeader,
      isInitialized: isInitialized ?? this.isInitialized,
      unlockedReward: unlockedReward,
    );
  }
}

/// 称号獲得通知を管理するProvider
/// home_screenでlistenManualを行い、handleReceivedChatCountUpdateを呼び出す
@riverpod
class RewardNotificationManager extends _$RewardNotificationManager {
  int? _pendingReceivedCount;
  int? _pendingPreviousCount;

  @override
  RewardNotificationState build() {
    // 初期化処理を開始
    _initializeRewardNotificationThreshold();

    return RewardNotificationState(
      maxNotifiedThreshold: 0,
      hasEarnedPartTimer: false,
      hasEarnedLeader: false,
      isInitialized: false,
    );
  }

  Future<void> _initializeRewardNotificationThreshold() async {
    final preferenceService = ref.read(preferenceServiceProvider);
    final stored =
        await preferenceService.getInt(
          PreferenceKey.maxReceivedChatRewardThresholdNotified,
        ) ??
        0;

    final hasEarnedPartTimer =
        await preferenceService.getBool(
          PreferenceKey.hasEarnedPartTimerReward,
        ) ??
        false;

    final hasEarnedLeader =
        await preferenceService.getBool(
          PreferenceKey.hasEarnedLeaderReward,
        ) ??
        false;

    state = state.copyWith(
      maxNotifiedThreshold: stored,
      hasEarnedPartTimer: hasEarnedPartTimer,
      hasEarnedLeader: hasEarnedLeader,
      isInitialized: true,
    );

    if (_pendingReceivedCount != null) {
      maybeNotifyRewardUnlocked(
        _pendingPreviousCount,
        _pendingReceivedCount!,
      );
      _pendingReceivedCount = null;
      _pendingPreviousCount = null;
    }
  }

  void handleReceivedChatCountUpdate(int? previous, int? current) {
    if (current == null) {
      return;
    }

    if (!state.isInitialized) {
      _pendingReceivedCount = current;
      _pendingPreviousCount = previous;
      return;
    }

    maybeNotifyRewardUnlocked(previous, current);
  }

  void maybeNotifyRewardUnlocked(int? previous, int current) {
    final newlyAchieved = CavivaraReward.highestAchieved(current);
    if (newlyAchieved == null) {
      return;
    }

    final newThreshold = newlyAchieved.threshold;
    if (newThreshold <= state.maxNotifiedThreshold) {
      return;
    }

    if (previous == null || previous >= newThreshold) {
      updateNotifiedThreshold(newThreshold);
      return;
    }

    // 称号ごとに獲得済みかどうかをチェック
    final hasEarned = switch (newlyAchieved) {
      CavivaraReward.partTimer => state.hasEarnedPartTimer,
      CavivaraReward.leader => state.hasEarnedLeader,
    };

    updateNotifiedThreshold(newThreshold);

    // まだ獲得していない場合のみ、獲得をマークして通知
    if (!hasEarned) {
      _markRewardAsEarned(newlyAchieved);
      state = state.copyWith(unlockedReward: newlyAchieved);
    }
  }

  void _markRewardAsEarned(CavivaraReward reward) {
    final preferenceService = ref.read(preferenceServiceProvider);

    switch (reward) {
      case CavivaraReward.partTimer:
        state = state.copyWith(hasEarnedPartTimer: true);
        unawaited(
          preferenceService.setBool(
            PreferenceKey.hasEarnedPartTimerReward,
            value: true,
          ),
        );
      case CavivaraReward.leader:
        state = state.copyWith(hasEarnedLeader: true);
        unawaited(
          preferenceService.setBool(
            PreferenceKey.hasEarnedLeaderReward,
            value: true,
          ),
        );
    }
  }

  void updateNotifiedThreshold(int threshold) {
    state = state.copyWith(maxNotifiedThreshold: threshold);
    final preferenceService = ref.read(preferenceServiceProvider);
    unawaited(
      preferenceService.setInt(
        PreferenceKey.maxReceivedChatRewardThresholdNotified,
        value: threshold,
      ),
    );
  }
}
