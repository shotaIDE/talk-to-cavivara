import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_message_exception.freezed.dart';

@freezed
sealed class SendMessageException
    with _$SendMessageException
    implements Exception {
  const factory SendMessageException.noNetwork() =
      SendMessageExceptionNoNetwork;

  const factory SendMessageException.uncategorized({required String message}) =
      SendMessageExceptionUncategorized;
}
