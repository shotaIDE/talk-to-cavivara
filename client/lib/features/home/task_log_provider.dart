import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/models/task.dart';
import 'package:house_worker/repositories/task_repository.dart';

// 完了済みタスクの一覧を提供するプロバイダー
final completedTasksProvider = FutureProvider<List<Task>>((ref) async {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return await taskRepository.getCompletedTasks();
});

// タイトルでタスクを検索するプロバイダー
final taskLogsByTitleProvider = FutureProvider.family<List<Task>, String>((
  ref,
  title,
) async {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return await taskRepository.getTasksByTitle(title);
});

// 削除されたタスクを一時的に保持するプロバイダー
final deletedTaskProvider = StateProvider<Task?>((ref) => null);

// タスク削除の取り消しタイマーを管理するプロバイダー
final undoDeleteTimerProvider = StateProvider<int?>((ref) => null);

// タスク削除処理を行うプロバイダー
final taskDeletionProvider = Provider((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);

  return TaskDeletionNotifier(taskRepository: taskRepository, ref: ref);
});

class TaskDeletionNotifier {
  final TaskRepository taskRepository;
  final Ref ref;

  TaskDeletionNotifier({required this.taskRepository, required this.ref});

  // タスクを削除する
  Future<void> deleteTask(Task task) async {
    // 削除前にタスクを保存
    ref.read(deletedTaskProvider.notifier).state = task;

    // タスクを削除
    await taskRepository.delete(task.id);

    // 既存のタイマーがあればキャンセル
    final existingTimerId = ref.read(undoDeleteTimerProvider);
    if (existingTimerId != null) {
      Future.delayed(Duration.zero, () {
        ref.invalidate(undoDeleteTimerProvider);
      });
    }

    // 5秒後に削除を確定するタイマーを設定
    final timerId = DateTime.now().millisecondsSinceEpoch;
    ref.read(undoDeleteTimerProvider.notifier).state = timerId;

    Future.delayed(const Duration(seconds: 5), () {
      final currentTimerId = ref.read(undoDeleteTimerProvider);
      if (currentTimerId == timerId) {
        // タイマーが変更されていなければ、削除を確定
        ref.read(deletedTaskProvider.notifier).state = null;
        ref.read(undoDeleteTimerProvider.notifier).state = null;
      }
    });
  }

  // 削除を取り消す
  Future<void> undoDelete() async {
    final deletedTask = ref.read(deletedTaskProvider);
    if (deletedTask != null) {
      // タスクを復元
      await taskRepository.save(deletedTask);

      // 状態をリセット
      ref.read(deletedTaskProvider.notifier).state = null;
      ref.read(undoDeleteTimerProvider.notifier).state = null;
    }
  }
}
