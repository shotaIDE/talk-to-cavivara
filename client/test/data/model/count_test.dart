import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class DocumentSnapshotInterface {
  String get id;
  Map<String, dynamic>? data();
}

class MockDocumentSnapshot extends Mock implements DocumentSnapshotInterface {}

void main() {
  group('Count', () {
    test('fromFirestore が正しく Count オブジェクトを作成すること', () {
      // モックの準備
      final mockDoc = MockDocumentSnapshot();
      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);
      const id = 'test-id';
      const countValue = 10;

      // モックの振る舞いを設定
      when(mockDoc.id).thenReturn(id);
      when(
        mockDoc.data(),
      ).thenReturn({'count': countValue, 'updatedAt': timestamp});

      // テスト対象のメソッドを実行
      final count = Count.fromFirestore(mockDoc);

      // 検証
      expect(count.id, equals(id));
      expect(count.count, equals(countValue));
      expect(count.updatedAt, equals(now));
    });

    test('toFirestore が正しく Map を返すこと', () {
      final now = DateTime.now();
      const id = 'test-id';
      const countValue = 15;

      final count = Count(id: id, count: countValue, updatedAt: now);

      final firestoreMap = count.toFirestore();

      expect(firestoreMap['count'], equals(countValue));
      // toFirestore メソッドでは 'createdAt' というキーで updatedAt の値を保存している
      expect(firestoreMap['createdAt'], equals(now));
    });

    test('toFirestore で返される Map に id が含まれないこと', () {
      final now = DateTime.now();
      const id = 'test-id';
      const countValue = 20;

      final count = Count(id: id, count: countValue, updatedAt: now);

      final firestoreMap = count.toFirestore();

      // id はFirestoreのドキュメントIDとして使用されるため、Mapには含まれないはず
      expect(firestoreMap.containsKey('id'), isFalse);
    });
  });
}
