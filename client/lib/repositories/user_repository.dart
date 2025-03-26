import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/models/user.dart' as app_user;
import 'package:logging/logging.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

class UserRepository {
  final Logger _logger = Logger('UserRepository');
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  // ユーザーを作成または更新
  Future<String> save(app_user.User user) async {
    if (user.id.isEmpty) {
      // 新規ユーザーの場合
      DocumentReference docRef = await _usersCollection.add(user.toFirestore());
      return docRef.id;
    } else {
      // 既存ユーザーの更新
      await _usersCollection.doc(user.id).update(user.toFirestore());
      return user.id;
    }
  }

  // 全ユーザーを取得
  Future<List<app_user.User>> getAll() async {
    QuerySnapshot querySnapshot = await _usersCollection.get();
    return querySnapshot.docs
        .map((doc) => app_user.User.fromFirestore(doc))
        .toList();
  }

  // IDでユーザーを取得
  Future<app_user.User?> getById(String id) async {
    DocumentSnapshot doc = await _usersCollection.doc(id).get();
    if (doc.exists) {
      return app_user.User.fromFirestore(doc);
    }
    return null;
  }

  // ユーザーを削除
  Future<bool> delete(String id) async {
    try {
      await _usersCollection.doc(id).delete();
      return true;
    } catch (e) {
      _logger.warning('ユーザー削除エラー: $e');
      return false;
    }
  }

  // Firebase UIDでユーザーを取得
  Future<app_user.User?> getUserByUid(String uid) async {
    QuerySnapshot querySnapshot =
        await _usersCollection.where('uid', isEqualTo: uid).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      return app_user.User.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }

  // ユーザーを作成
  Future<String> createUser(app_user.User user) async {
    return await save(user);
  }

  // ユーザーを更新
  Future<void> updateUser(app_user.User user) async {
    await save(user);
  }

  // 全ユーザーを取得
  Future<List<app_user.User>> getAllUsers() async {
    return await getAll();
  }
}
