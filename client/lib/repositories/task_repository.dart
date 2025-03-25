import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/models/task.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

class TaskRepository {
  final CollectionReference _tasksCollection = FirebaseFirestore.instance
      .collection('tasks');

  Future<String> save(Task task) async {
    if (task.id.isEmpty) {
      // 新規タスクの場合
      DocumentReference docRef = await _tasksCollection.add(task.toFirestore());
      return docRef.id;
    } else {
      // 既存タスクの更新
      await _tasksCollection.doc(task.id).update(task.toFirestore());
      return task.id;
    }
  }

  Future<List<String>> saveAll(List<Task> tasks) async {
    List<String> ids = [];
    for (var task in tasks) {
      String id = await save(task);
      ids.add(id);
    }
    return ids;
  }

  Future<Task?> getById(String id) async {
    DocumentSnapshot doc = await _tasksCollection.doc(id).get();
    if (doc.exists) {
      return Task.fromFirestore(doc);
    }
    return null;
  }

  Future<List<Task>> getAll() async {
    QuerySnapshot querySnapshot = await _tasksCollection.get();
    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<bool> delete(String id) async {
    try {
      await _tasksCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('タスク削除エラー: $e');
      return false;
    }
  }

  Future<void> deleteAll() async {
    QuerySnapshot querySnapshot = await _tasksCollection.get();
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<List<Task>> getIncompleteTasks() async {
    QuerySnapshot querySnapshot =
        await _tasksCollection
            .where('isCompleted', isEqualTo: false)
            .orderBy('priority', descending: true)
            .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<List<Task>> getCompletedTasks() async {
    QuerySnapshot querySnapshot =
        await _tasksCollection
            .where('isCompleted', isEqualTo: true)
            .orderBy('completedAt', descending: true)
            .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<List<Task>> getTasksByUser(String userId) async {
    // createdByまたはcompletedByがuserIdに一致するタスクを取得
    QuerySnapshot createdBySnapshot =
        await _tasksCollection.where('createdBy', isEqualTo: userId).get();

    QuerySnapshot completedBySnapshot =
        await _tasksCollection.where('completedBy', isEqualTo: userId).get();

    // 結果をマージして重複を排除
    Set<String> processedIds = {};
    List<Task> tasks = [];

    for (var doc in createdBySnapshot.docs) {
      if (!processedIds.contains(doc.id)) {
        tasks.add(Task.fromFirestore(doc));
        processedIds.add(doc.id);
      }
    }

    for (var doc in completedBySnapshot.docs) {
      if (!processedIds.contains(doc.id)) {
        tasks.add(Task.fromFirestore(doc));
        processedIds.add(doc.id);
      }
    }

    return tasks;
  }

  Future<List<Task>> getSharedTasks() async {
    QuerySnapshot querySnapshot =
        await _tasksCollection
            .where('isShared', isEqualTo: true)
            .orderBy('priority', descending: true)
            .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<List<Task>> getRecurringTasks() async {
    QuerySnapshot querySnapshot =
        await _tasksCollection
            .where('isRecurring', isEqualTo: true)
            .orderBy('priority', descending: true)
            .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<void> completeTask(Task task, String userId) async {
    task.isCompleted = true;
    task.completedAt = DateTime.now();
    task.completedBy = userId;

    await _tasksCollection.doc(task.id).update(task.toFirestore());
  }

  Future<List<Task>> getTasksByTitle(String title) async {
    QuerySnapshot querySnapshot =
        await _tasksCollection
            .where('title', isEqualTo: title)
            .orderBy('completedAt', descending: true)
            .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }
}
