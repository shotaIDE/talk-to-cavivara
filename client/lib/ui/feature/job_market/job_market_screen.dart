import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/service/cavivara_directory_service.dart';
import 'package:house_worker/data/service/employment_state_service.dart';
import 'package:house_worker/ui/component/app_drawer.dart';
import 'package:house_worker/ui/component/cavivara_avatar.dart';
import 'package:house_worker/ui/feature/home/home_screen.dart';
import 'package:house_worker/ui/feature/resume/resume_screen.dart';
import 'package:house_worker/ui/feature/settings/settings_screen.dart';

class JobMarketScreen extends ConsumerWidget {
  const JobMarketScreen({super.key});

  static const name = 'JobMarketScreen';

  static MaterialPageRoute<JobMarketScreen> route() =>
      MaterialPageRoute<JobMarketScreen>(
        builder: (_) => const JobMarketScreen(),
        settings: const RouteSettings(name: name),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCavivaras = ref.watch(cavivaraDirectoryProvider);
    final employmentState = ref.watch(employmentStateProvider);
    final defaultCavivaraId = employmentState.isNotEmpty
        ? employmentState.first
        : HomeScreen.defaultCavivaraId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('転職市場'),
        centerTitle: true,
      ),
      drawer: AppDrawer(
        isTalkSelected: false,
        isJobMarketSelected: true,
        onSelectTalk: () {
          Navigator.of(context).pushAndRemoveUntil(
            HomeScreen.route(defaultCavivaraId),
            (route) => false,
          );
        },
        onSelectJobMarket: () {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        },
        onSelectSettings: () {
          Navigator.of(context).push(SettingsScreen.route());
        },
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 16 + MediaQuery.of(context).viewPadding.left,
          right: 16 + MediaQuery.of(context).viewPadding.right,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        children: [
          for (final cavivara in allCavivaras) ...[
            _CavivaraListItem(
              cavivaraId: cavivara.id,
              displayName: cavivara.displayName,
              title: cavivara.title,
              iconPath: cavivara.iconPath,
              isEmployed: employmentState.contains(cavivara.id),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _CavivaraListItem extends StatelessWidget {
  const _CavivaraListItem({
    required this.cavivaraId,
    required this.displayName,
    required this.title,
    required this.iconPath,
    required this.isEmployed,
  });

  final String cavivaraId;
  final String displayName;
  final String title;
  final String iconPath;
  final bool isEmployed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToResume(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CavivaraAvatar(
                    size: 64,
                    assetPath: iconPath,
                    cavivaraId: cavivaraId,
                    semanticsLabel: '$displayNameのアバター',
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (isEmployed) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '雇用中',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (isEmployed) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToChat(context),
                        icon: const Icon(Icons.chat),
                        label: const Text('相談する'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 履歴書画面に遷移
  void _navigateToResume(BuildContext context) {
    Navigator.of(context).push(ResumeScreen.route(cavivaraId));
  }

  /// チャット画面に遷移
  void _navigateToChat(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      HomeScreen.route(cavivaraId),
      (route) => false,
    );
  }
}
