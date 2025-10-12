import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/ui/component/heads_up_notification_presenter.dart';

class HeadsUpNotificationOverlay extends ConsumerWidget {
  const HeadsUpNotificationOverlay({
    super.key,
    required this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(headsUpNotificationProvider);

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
    final controller = ref.read(headsUpNotificationProvider.notifier);

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
