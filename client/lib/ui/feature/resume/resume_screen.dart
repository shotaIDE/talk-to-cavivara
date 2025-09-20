import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/data/service/cavivara_directory_service.dart';
import 'package:house_worker/data/service/employment_state_service.dart';
import 'package:house_worker/ui/component/cavivara_avatar.dart';
import 'package:house_worker/ui/feature/home/home_screen.dart';

class ResumeScreen extends ConsumerWidget {
  const ResumeScreen({super.key, required this.cavivaraId});

  /// 表示対象のカヴィヴァラID
  final String cavivaraId;

  static const name = 'ResumeScreen';

  static MaterialPageRoute<ResumeScreen> route(String cavivaraId) =>
      MaterialPageRoute<ResumeScreen>(
        builder: (_) => ResumeScreen(cavivaraId: cavivaraId),
        settings: const RouteSettings(name: name),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cavivaraProfile = ref.watch(cavivaraByIdProvider(cavivaraId));
    final isEmployed = ref.watch(isEmployedProvider(cavivaraId));
    final employmentStateNotifier = ref.read(employmentStateProvider.notifier);

    Widget sectionTitle(String text) {
      return Text(
        text,
        style: theme.textTheme.titleLarge,
      );
    }

    Widget bulletList(List<String> items) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${cavivaraProfile.displayName}の履歴書'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                left: 16 + MediaQuery.of(context).viewPadding.left,
                right: 16 + MediaQuery.of(context).viewPadding.right,
                top: 16,
                bottom: 16,
              ),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CavivaraAvatar(
                              size: 96,
                              assetPath: cavivaraProfile.iconPath,
                              cavivaraId: cavivaraId,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cavivaraProfile.displayName,
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cavivaraProfile.title,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    cavivaraProfile.description,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final tag in cavivaraProfile.tags)
                              Chip(label: Text(tag)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // 履歴書セクションを動的に生成
                for (final section in cavivaraProfile.resumeSections) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sectionTitle(section.title),
                          const SizedBox(height: 12),
                          bulletList(section.items),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 画面下部に固定表示される雇用ボタン
          Container(
            color: theme.colorScheme.surface,
            padding: EdgeInsets.only(
              left: 16 + MediaQuery.of(context).viewPadding.left,
              right: 16 + MediaQuery.of(context).viewPadding.right,
              top: 16,
              bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isEmployed) ...[
                  ElevatedButton.icon(
                    onPressed: () => _fireAndNavigateToJobMarket(
                      context,
                      employmentStateNotifier,
                    ),
                    icon: const Icon(Icons.work_off),
                    label: const Text('解雇する'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onError,
                      backgroundColor: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _navigateToChat(context),
                    icon: const Icon(Icons.chat),
                    label: const Text('相談する'),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: () => _hireAndNavigateToChat(
                      context,
                      employmentStateNotifier,
                    ),
                    icon: const Icon(Icons.work),
                    label: const Text('雇用する'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 雇用してチャット画面に遷移
  void _hireAndNavigateToChat(
    BuildContext context,
    EmploymentState employmentStateNotifier,
  ) {
    employmentStateNotifier.hire(cavivaraId);
    Navigator.of(context).pushReplacement(HomeScreen.route(cavivaraId));
  }

  /// 解雇して転職市場画面に戻る
  void _fireAndNavigateToJobMarket(
    BuildContext context,
    EmploymentState employmentStateNotifier,
  ) {
    employmentStateNotifier.fire(cavivaraId);
    // TODO(job-market): 転職市場画面が実装されたら以下のコメントアウトを解除
    // Navigator.of(context).pushReplacement(JobMarketScreen.route());
    Navigator.of(context).pop(); // 現在は前の画面に戻る
  }

  /// チャット画面に遷移
  void _navigateToChat(BuildContext context) {
    Navigator.of(context).pushReplacement(HomeScreen.route(cavivaraId));
  }
}
