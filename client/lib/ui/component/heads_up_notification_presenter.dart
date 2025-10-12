import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'heads_up_notification_presenter.freezed.dart';
part 'heads_up_notification_presenter.g.dart';

@freezed
sealed class HeadsUpNotificationData with _$HeadsUpNotificationData {
  const factory HeadsUpNotificationData({
    required String title,
    required String message,
    VoidCallback? onTap,
  }) = _HeadsUpNotificationData;
}

@freezed
sealed class HeadsUpNotificationState with _$HeadsUpNotificationState {
  const factory HeadsUpNotificationState.hidden() = _Hidden;

  const factory HeadsUpNotificationState.visible(
    HeadsUpNotificationData notification,
  ) = _Visible;
}

@riverpod
class HeadsUpNotification extends _$HeadsUpNotification {
  Timer? _dismissTimer;

  @override
  HeadsUpNotificationState build() {
    ref.onDispose(() {
      _dismissTimer?.cancel();
    });
    return const HeadsUpNotificationState.hidden();
  }

  void show(HeadsUpNotificationData notification) {
    _dismissTimer?.cancel();
    state = HeadsUpNotificationState.visible(notification);
    _dismissTimer = Timer(const Duration(seconds: 5), hide);
  }

  void hide() {
    _dismissTimer?.cancel();
    state = const HeadsUpNotificationState.hidden();
  }

  void handleTap() {
    state.whenOrNull(
      visible: (notification) {
        hide();
        notification.onTap?.call();
      },
    );
  }
}
