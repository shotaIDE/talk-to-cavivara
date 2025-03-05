import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_worker/models/user.dart';
import 'package:house_worker/repositories/base_repository.dart';
import 'package:isar/isar.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return UserRepository(isar);
});

class UserRepository extends BaseRepository {
  UserRepository(Isar isar) : super(isar);

  // ユーザーを作成
  Future<void> createUser(User user) async {
    await isar.writeTxn(() async {
      await isar.users.put(user);
    });
  }

  // Firebase UIDでユーザーを取得
  Future<User?> getUserByUid(String uid) async {
    return await isar.users.filter().uidEqualTo(uid).findFirst();
  }

  // ユーザーを更新
  Future<void> updateUser(User user) async {
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
  Future<List<User>> getAllUsers() async {
    return await isar.users.where().findAll();
  }
}
