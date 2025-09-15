import 'package:house_worker/data/model/chat_message.dart';
import 'package:house_worker/data/service/ai_chat_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_presenter.g.dart';

/// チャットメッセージのリストを管理するプロバイダー
@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  List<ChatMessage> build() => [];

  /// ユーザーメッセージを追加し、AIからの返信を取得する
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

    try {
      final aiChatService = ref.read(aiChatServiceProvider);
      final response = await aiChatService.sendMessage(content);

      final aiMessageId = '${DateTime.now().millisecondsSinceEpoch}_ai';
      final aiMessage = ChatMessage(
        id: aiMessageId,
        content: response,
        sender: const ChatMessageSender.ai(),
        timestamp: DateTime.now(),
      );

      // AIメッセージを追加
      state = [...state, aiMessage];
    } on Exception catch (e) {
      final errorMessageId = '${DateTime.now().millisecondsSinceEpoch}_error';
      final errorMessage = ChatMessage(
        id: errorMessageId,
        content: 'エラーが発生しました: $e',
        sender: const ChatMessageSender.ai(),
        timestamp: DateTime.now(),
      );

      state = [...state, errorMessage];
    }
  }

  /// チャット履歴をクリアする
  void clearMessages() {
    state = [];
  }
}
