import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/models/task.dart';
import 'package:logging/logging.dart';

final _logger = Logger('TaskRepository');

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ハウスIDを指定してタスクコレクションの参照を取得
  CollectionReference _getTasksCollection(String houseId) {
    return _firestore.collection('houses').doc(houseId).collection('tasks');
  }

  Future<String> save(String houseId, Task task) async {
    final tasksCollection = _getTasksCollection(houseId);

    if (task.id.isEmpty) {
      // 新規タスクの場合
      DocumentReference docRef = await tasksCollection.add(task.toFirestore());
      return docRef.id;
    } else {
      // 既存タスクの更新
      await tasksCollection.doc(task.id).update(task.toFirestore());
      return task.id;
    }
  }

  Future<List<String>> saveAll(String houseId, List<Task> tasks) async {
    List<String> ids = [];
    for (var task in tasks) {
      String id = await save(houseId, task);
      ids.add(id);
    }
    return ids;
  }

  Future<Task?> getById(String houseId, String id) async {
    DocumentSnapshot doc = await _getTasksCollection(houseId).doc(id).get();
    if (doc.exists) {
      return Task.fromFirestore(doc);
    }
    return null;
  }

  Future<List<Task>> getAll(String houseId) async {
    QuerySnapshot querySnapshot = await _getTasksCollection(houseId).get();
    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<bool> delete(String houseId, String id) async {
    try {
      await _getTasksCollection(houseId).doc(id).delete();
      return true;
    } catch (e) {
      _logger.warning('タスク削除エラー', e);
      return false;
    }
  }

  Future<void> deleteAll(String houseId) async {
    QuerySnapshot querySnapshot = await _getTasksCollection(houseId).get();
    WriteBatch batch = _firestore.batch();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<List<Task>> getIncompleteTasks(String houseId) async {
    QuerySnapshot querySnapshot =
        await _getTasksCollection(houseId)
            .where('isCompleted', isEqualTo: false)
            .orderBy('priority', descending: true)
            .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<List<Task>> getCompletedTasks(String houseId) async {
    QuerySnapshot querySnapshot =
        await _getTasksCollection(houseId)
            .where('isCompleted', isEqualTo: true)
            .orderBy('completedAt', descending: true)
            .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<List<Task>> getTasksByUser(String houseId, String userId) async {
    // createdByまたはcompletedByがuserIdに一致するタスクを取得
    QuerySnapshot createdBySnapshot =
        await _getTasksCollection(
          houseId,
        ).where('createdBy', isEqualTo: userId).get();

    QuerySnapshot completedBySnapshot =
        await _getTasksCollection(
          houseId,
        ).where('completedBy', isEqualTo: userId).get();

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

  Future<List<Task>> getSharedTasks(String houseId) async {
    QuerySnapshot querySnapshot =
        await _getTasksCollection(houseId)
            .where('isShared', isEqualTo: true)
            .orderBy('priority', descending: true)
            .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<List<Task>> getRecurringTasks(String houseId) async {
    QuerySnapshot querySnapshot =
        await _getTasksCollection(houseId)
            .where('isRecurring', isEqualTo: true)
            .orderBy('priority', descending: true)
            .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<void> completeTask(String houseId, Task task, String userId) async {
    task.isCompleted = true;
    task.completedAt = DateTime.now();
    task.completedBy = userId;

    await _getTasksCollection(houseId).doc(task.id).update(task.toFirestore());
  }

  Future<List<Task>> getTasksByTitle(String houseId, String title) async {
    QuerySnapshot querySnapshot =
        await _getTasksCollection(houseId)
            .where('title', isEqualTo: title)
            .orderBy('completedAt', descending: true)
            .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  // 権限チェック用のメソッド
  Future<bool> hasPermission(String houseId, String userId) async {
    DocumentSnapshot permissionDoc =
        await _firestore
            .collection('permissions')
            .doc(houseId)
            .collection('admin')
            .doc(userId)
            .get();

    return permissionDoc.exists;
  }
}
