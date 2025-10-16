import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// 通知
///
/// Firebase Remote Config から取得したお知らせ情報を保持する
@freezed
abstract class Notification with _$Notification {
  const factory Notification({
    /// 通知の一意識別子
    required String id,

    /// 通知タイトル
    required String title,

    /// 通知本文
    required String body,

    /// 公開日時
    required DateTime publishedAt,

    /// 詳細URL
    String? detailUrl,
  }) = _Notification;

  const Notification._();

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
}
