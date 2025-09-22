import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/model/chat_message.dart';
import 'package:house_worker/data/service/ai_chat_service.dart';
import 'package:house_worker/data/service/cavivara_directory_service.dart';
import 'package:house_worker/ui/usecase/last_talked_cavivara_usecase.dart';
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
    try {
      final responseStream = aiChatService.sendMessageStream(
        content,
        systemPrompt: systemPrompt,
        conversationHistory: conversationHistory,
      );
      var buffer = '';

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
    } on Exception catch (e) {
      hasError = true;
      updateAiMessage(
        (message) => message.copyWith(
          content: 'エラーが発生しました: $e',
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
  await ref
      .read(lastTalkedCavivaraIdProvider.notifier)
      .updateCavivaraId(cavivaraId);
}
