import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/models/user.dart' as app_user;
import 'package:house_worker/repositories/base_repository.dart';
import 'package:isar/isar.dart';
import 'package:house_worker/main.dart'; // isarProviderをインポート

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return UserRepository(isar);
});

class UserRepository extends BaseRepository<app_user.User> {
  UserRepository(Isar isar) : super(isar, isar.collection<app_user.User>());

  // ユーザーを作成
  Future<void> createUser(app_user.User user) async {
    await isar.writeTxn(() async {
      await isar.users.put(user);
    });
  }

  // Firebase UIDでユーザーを取得
  Future<app_user.User?> getUserByUid(String uid) async {
    return await isar.users.filter().uidEqualTo(uid).findFirst();
  }

  // ユーザーを更新
  Future<void> updateUser(app_user.User user) async {
    await isar.writeTxn(() async {
      await isar.users.put(user);
    });
  }

  // ユーザーを削除
  Future<void> deleteUser(int id) async {
    await isar.writeTxn(() async {
      await isar.users.delete(id);
    });
  }

  // 全ユーザーを取得
  Future<List<app_user.User>> getAllUsers() async {
    return await isar.users.where().findAll();
  }
}
