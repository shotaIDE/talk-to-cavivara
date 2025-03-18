import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    // 優先度に応じた色を取得
    Color getPriorityColor() {
      switch (task.priority) {
        case 1:
          return Colors.green;
        case 2:
          return Colors.orange;
        case 3:
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    // 優先度に応じたラベルを取得
    String getPriorityLabel() {
      switch (task.priority) {
        case 1:
          return '低';
        case 2:
          return '中';
        case 3:
          return '高';
        default:
          return '-';
      }
    }

    // 優先度に応じたアイコンを取得
    IconData getPriorityIcon() {
      switch (task.priority) {
        case 1:
          return Icons.arrow_downward;
        case 2:
          return Icons.remove;
        case 3:
          return Icons.arrow_upward;
        default:
          return Icons.help_outline;
      }
    }

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
                    Icon(getPriorityIcon(), color: getPriorityColor()),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        '重要度: ${getPriorityLabel()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: getPriorityColor(),
                    ),
                    const SizedBox(width: 8),
                    if (task.isRecurring)
                      const Chip(
                        label: Text('繰り返し'),
                        backgroundColor: Colors.blue,
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
