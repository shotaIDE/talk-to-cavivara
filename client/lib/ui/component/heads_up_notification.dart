import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'heads_up_notification.freezed.dart';

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

class HeadsUpNotificationController extends Notifier<HeadsUpNotificationState> {
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

final headsUpNotificationControllerProvider =
    NotifierProvider<HeadsUpNotificationController, HeadsUpNotificationState>(
      HeadsUpNotificationController.new,
    );

class HeadsUpNotificationOverlay extends ConsumerWidget {
  const HeadsUpNotificationOverlay({
    super.key,
    required this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(headsUpNotificationControllerProvider);

    return Stack(
      children: [
        child ?? const SizedBox.shrink(),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            minimum: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Align(
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
                child: state.when(
                  hidden: () => const SizedBox.shrink(),
                  visible: (notification) =>
                      _HeadsUpNotificationCard(notification: notification),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeadsUpNotificationCard extends ConsumerWidget {
  const _HeadsUpNotificationCard({
    required this.notification,
  });

  final HeadsUpNotificationData notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.read(headsUpNotificationControllerProvider.notifier);

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: controller.handleTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.emoji_events,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      notification.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
