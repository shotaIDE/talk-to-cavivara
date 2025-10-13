import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/repository/has_earned_leader_reward_repository.dart';
import 'package:house_worker/data/repository/has_earned_part_timer_reward_repository.dart';
import 'package:house_worker/data/repository/received_chat_string_count_repository.dart';
import 'package:house_worker/data/repository/skip_clear_chat_confirmation_repository.dart';
import 'package:house_worker/ui/feature/settings/section_header.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  static const name = 'DebugScreen';

  static MaterialPageRoute<DebugScreen> route() =>
      MaterialPageRoute<DebugScreen>(
        builder: (_) => const DebugScreen(),
        settings: const RouteSettings(name: name),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('デバッグ')),
      body: ListView(
        children: const [
          SectionHeader(title: 'Crashlytics'),
          _ForceErrorTile(),
          _ForceCrashTile(),
          SectionHeader(title: '設定リセット'),
          _ResetConfirmationSettingsTile(),
          SectionHeader(title: '統計リセット'),
          _ResetReceivedChatCountAndAchievementsTile(),
        ],
      ),
    );
  }
}

class _ForceCrashTile extends StatelessWidget {
  const _ForceCrashTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('強制クラッシュ'),
      onTap: () => FirebaseCrashlytics.instance.crash(),
    );
  }
}

class _ForceErrorTile extends StatelessWidget {
  const _ForceErrorTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(title: const Text('強制エラー'), onTap: () => throw Exception());
  }
}

class _ResetConfirmationSettingsTile extends ConsumerWidget {
  const _ResetConfirmationSettingsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: const Text('記憶消去の確認ダイアログの設定をリセット'),
      onTap: () async {
        await ref
            .read(skipClearChatConfirmationProvider.notifier)
            .updateSkip(shouldSkip: false);
      },
    );
  }
}

class _ResetReceivedChatCountAndAchievementsTile extends ConsumerWidget {
  const _ResetReceivedChatCountAndAchievementsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: const Text('受信チャット文字数と称号をリセット'),
      onTap: () async {
        await ref
            .read(receivedChatStringCountRepositoryProvider.notifier)
            .reset();
        await ref
            .read(hasEarnedLeaderRewardRepositoryProvider.notifier)
            .reset();
        await ref
            .read(hasEarnedPartTimerRewardRepositoryProvider.notifier)
            .reset();
      },
    );
  }
}
