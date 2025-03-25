import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/features/home/task_log_add_screen.dart';
import 'package:house_worker/features/home/task_log_provider.dart';
import 'package:house_worker/models/task.dart';
import 'package:intl/intl.dart';

class TaskLogItem extends ConsumerWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskLogItem({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 日付フォーマッター
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

    return Dismissible(
      key: Key('task-${task.id}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // タスク削除処理
        ref.read(taskDeletionProvider).deleteTask(task);

        // スナックバーを表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.delete, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text('家事ログを削除しました')),
              ],
            ),
            action: SnackBarAction(
              label: '元に戻す',
              onPressed: () {
                // 削除を取り消す
                ref.read(taskDeletionProvider).undoDelete();
              },
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // アイコンを表示
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(right: 12),
                      child: Text(
                        task.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // 記録ボタンを追加
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'この家事を記録する',
                      onPressed: () {
                        // 家事ログ追加画面に遷移し、タスク情報を渡す
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    TaskLogAddScreen.fromExistingTask(task),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Text(
                        '完了: ${dateFormat.format(task.completedAt ?? DateTime.now())}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 1,
                      child: Text(
                        '実行者: ${task.completedBy ?? "不明"}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
