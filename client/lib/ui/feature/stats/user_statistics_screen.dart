import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/model/user_statistics.dart';
import 'package:house_worker/data/repository/user_statistics_repository.dart';
import 'package:house_worker/data/service/employment_state_service.dart';
import 'package:house_worker/ui/component/app_drawer.dart';
import 'package:house_worker/ui/feature/home/home_screen.dart';
import 'package:house_worker/ui/feature/job_market/job_market_screen.dart';
import 'package:house_worker/ui/feature/settings/settings_screen.dart';

class UserStatisticsScreen extends ConsumerWidget {
  const UserStatisticsScreen({super.key});

  static const name = 'UserStatisticsScreen';

  static MaterialPageRoute<UserStatisticsScreen> route() =>
      MaterialPageRoute<UserStatisticsScreen>(
        builder: (_) => const UserStatisticsScreen(),
        settings: const RouteSettings(name: name),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employmentState = ref.watch(employmentStateProvider);
    final defaultCavivaraId = employmentState.isNotEmpty
        ? employmentState.first
        : HomeScreen.defaultCavivaraId;
    final statistics = ref.watch(userStatisticsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('あなたの業績'),
      ),
      drawer: AppDrawer(
        isTalkSelected: false,
        isJobMarketSelected: false,
        isAchievementSelected: true,
        onSelectTalk: () {
          Navigator.of(context).pushAndRemoveUntil(
            HomeScreen.route(defaultCavivaraId),
            (route) => false,
          );
        },
        onSelectJobMarket: () {
          Navigator.of(context).pushAndRemoveUntil(
            JobMarketScreen.route(),
            (route) => false,
          );
        },
        onSelectAchievement: () {
          Navigator.of(context).pop();
        },
        onSelectSettings: () {
          Navigator.of(context).push(SettingsScreen.route());
        },
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 16 + MediaQuery.of(context).viewPadding.left,
          right: 16 + MediaQuery.of(context).viewPadding.right,
          top: 24,
          bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: statistics.when(
          data: (data) => _StatisticsContent(statistics: data),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              'データの取得に失敗しました',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent({required this.statistics});

  final UserStatistics statistics;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _StatisticsTile(
          title: 'チャットを送信した文字数',
          value: '${statistics.sentCharacters}文字',
          icon: Icons.outgoing_mail,
        ),
        const SizedBox(height: 16),
        _StatisticsTile(
          title: 'カヴィヴァラさんたちから受信したチャットの文字数',
          value: '${statistics.receivedCharacters}文字',
          icon: Icons.inbox,
        ),
        const SizedBox(height: 16),
        _StatisticsTile(
          title: 'カヴィヴァラさんの履歴書を眺めていた時間',
          value: _formatDuration(statistics.resumeViewingDuration),
          icon: Icons.schedule,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration <= Duration.zero) {
      return '0秒';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    final buffer = <String>[];

    if (hours > 0) {
      buffer.add('${hours}時間');
    }
    if (minutes > 0) {
      buffer.add('${minutes}分');
    }
    if (seconds > 0 || buffer.isEmpty) {
      buffer.add('${seconds}秒');
    }

    return buffer.join();
  }
}

class _StatisticsTile extends StatelessWidget {
  const _StatisticsTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
