import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/features/home/task_log_provider.dart';
import 'package:house_worker/models/task.dart';
import 'package:intl/intl.dart';

class TaskDashboardScreen extends ConsumerWidget {
  final Task task;

  const TaskDashboardScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 日付フォーマッター
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

    // この家事に関連するログを取得
    final taskLogsAsyncValue = ref.watch(taskLogsByTitleProvider(task.title));

    return Scaffold(
      appBar: AppBar(title: Text('${task.title}のダッシュボード')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // メイン情報カード
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // アイコンを表示
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(
                              26, // 0.1 = 約10%の透明度 = 255 * 0.1 ≈ 26
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(right: 16),
                          child: Text(
                            task.icon,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 完了ログ件数
                    taskLogsAsyncValue.when(
                      data: (logs) => _buildCompletionStats(context, logs),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('エラーが発生しました: $err'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 完了ログ一覧
            const Text(
              '完了ログ一覧',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            taskLogsAsyncValue.when(
              data:
                  (logs) =>
                      logs.isEmpty
                          ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('完了ログはありません'),
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(
                                    '完了: ${dateFormat.format(log.completedAt ?? DateTime.now())}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '実行者: ${log.completedBy ?? "不明"}',
                                  ),
                                ),
                              );
                            },
                          ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('エラーが発生しました: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionStats(BuildContext context, List<Task> logs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 36),
          const SizedBox(width: 16),
          Text(
            '完了回数: ${logs.length}回',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
