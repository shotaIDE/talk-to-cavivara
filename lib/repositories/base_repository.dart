import 'package:isar/isar.dart';

abstract class BaseRepository<T> {
  final Isar isar;
  final IsarCollection<T> collection;

  BaseRepository(this.isar) : collection = isar.collection();

  Future<int> save(T entity) async {
    return await isar.writeTxn(() async {
      return await collection.put(entity);
    });
  }

  Future<List<int>> saveAll(List<T> entities) async {
    return await isar.writeTxn(() async {
      return await collection.putAll(entities);
    });
  }

  Future<T?> getById(int id) async {
    return await collection.get(id);
  }

  Future<List<T>> getAll() async {
    return await collection.where().findAll();
  }

  Future<bool> delete(int id) async {
    return await isar.writeTxn(() async {
      return await collection.delete(id);
    });
  }

  Future<int> deleteAll() async {
    return await isar.writeTxn(() async {
      return collection.clear();
    });
  }
}
