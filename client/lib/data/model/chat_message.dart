import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

@freezed
sealed class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String content,
    required ChatMessageSender sender,
    required DateTime timestamp,
  }) = _ChatMessage;
}

@freezed
sealed class ChatMessageSender with _$ChatMessageSender {
  const factory ChatMessageSender.user() = ChatMessageSenderUser;
  const factory ChatMessageSender.ai() = ChatMessageSenderAi;
}
