import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/models/task.dart';
import 'package:house_worker/repositories/base_repository.dart';
import 'package:isar/isar.dart';
import 'package:house_worker/main.dart'; // isarProviderをインポート

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return TaskRepository(isar);
});

class TaskRepository extends BaseRepository<Task> {
  TaskRepository(Isar isar) : super(isar, isar.collection<Task>());

  Future<List<Task>> getIncompleteTasks() async {
    return await this.collection
        .filter()
        .isCompletedEqualTo(false)
        .sortByPriority()
        .findAll();
  }

  Future<List<Task>> getCompletedTasks() async {
    return await this.collection
        .filter()
        .isCompletedEqualTo(true)
        .sortByCompletedAt()
        .findAll();
  }

  Future<List<Task>> getTasksByUser(String userId) async {
    return await this.collection
        .filter()
        .createdByEqualTo(userId)
        .or()
        .completedByEqualTo(userId)
        .findAll();
  }

  Future<List<Task>> getSharedTasks() async {
    return await this.collection
        .filter()
        .isSharedEqualTo(true)
        .sortByPriority()
        .findAll();
  }

  Future<List<Task>> getRecurringTasks() async {
    return await this.collection
        .filter()
        .isRecurringEqualTo(true)
        .sortByPriority()
        .findAll();
  }

  Future<void> completeTask(Task task, String userId) async {
    await isar.writeTxn(() async {
      task.isCompleted = true;
      task.completedAt = DateTime.now();
      task.completedBy = userId;
      await this.collection.put(task);
    });
  }
}
