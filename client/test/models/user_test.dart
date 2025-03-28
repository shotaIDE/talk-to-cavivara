import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_worker/models/user.dart';

void main() {
  group('User Model Tests', () {
    // テスト用のデータ
    final testId = 'test-id';
    final testUid = 'test-uid';
    final testName = 'テストユーザー';
    final testEmail = 'test@example.com';
    final testHouseholdIds = ['household-1', 'household-2'];
    final testCreatedAt = DateTime(2023, 1, 1);
    final testIsPremium = true;

    test('Userモデルが正しく作成されること', () {
      final user = User(
        id: testId,
        uid: testUid,
        name: testName,
        email: testEmail,
        householdIds: testHouseholdIds,
        createdAt: testCreatedAt,
        isPremium: testIsPremium,
      );

      expect(user.id, equals(testId));
      expect(user.uid, equals(testUid));
      expect(user.name, equals(testName));
      expect(user.email, equals(testEmail));
      expect(user.householdIds, equals(testHouseholdIds));
      expect(user.createdAt, equals(testCreatedAt));
      expect(user.isPremium, equals(testIsPremium));
    });

    test('デフォルト値が正しく設定されること', () {
      final user = User(
        id: testId,
        uid: testUid,
        name: testName,
        email: testEmail,
        householdIds: testHouseholdIds,
        createdAt: testCreatedAt,
      );

      expect(user.isPremium, equals(false)); // デフォルト値のテスト
    });

    test('toFirestore()が正しいMapを返すこと', () {
      final user = User(
        id: testId,
        uid: testUid,
        name: testName,
        email: testEmail,
        householdIds: testHouseholdIds,
        createdAt: testCreatedAt,
        isPremium: testIsPremium,
      );

      final firestoreMap = user.toFirestore();
      
      expect(firestoreMap['uid'], equals(testUid));
      expect(firestoreMap['name'], equals(testName));
      expect(firestoreMap['email'], equals(testEmail));
      expect(firestoreMap['householdIds'], equals(testHouseholdIds));
      expect(firestoreMap['isPremium'], equals(testIsPremium));
      expect(firestoreMap['createdAt'], isA<Timestamp>());
    });

    test('fromFirestore()が正しくUserオブジェクトを作成すること', () {
      // Firestoreのドキュメントスナップショットをモック
      final mockData = {
        'uid': testUid,
        'name': testName,
        'email': testEmail,
        'householdIds': testHouseholdIds,
        'createdAt': Timestamp.fromDate(testCreatedAt),
        'isPremium': testIsPremium,
      };

      final mockDocSnapshot = MockDocumentSnapshot(testId, mockData);
      
      final user = User.fromFirestore(mockDocSnapshot);
      
      expect(user.id, equals(testId));
      expect(user.uid, equals(testUid));
      expect(user.name, equals(testName));
      expect(user.email, equals(testEmail));
      expect(user.householdIds, equals(testHouseholdIds));
      expect(user.createdAt, equals(testCreatedAt));
      expect(user.isPremium, equals(testIsPremium));
    });

    test('fromFirestore()が欠損データに対してデフォルト値を設定すること', () {
      // 一部のフィールドが欠けているデータ
      final mockIncompleteData = {
        'uid': testUid,
        'createdAt': Timestamp.fromDate(testCreatedAt),
      };

      final mockDocSnapshot = MockDocumentSnapshot(testId, mockIncompleteData);
      
      final user = User.fromFirestore(mockDocSnapshot);
      
      expect(user.id, equals(testId));
      expect(user.uid, equals(testUid));
      expect(user.name, equals(''));
      expect(user.email, equals(''));
      expect(user.householdIds, isEmpty);
      expect(user.createdAt, equals(testCreatedAt));
      expect(user.isPremium, equals(false));
    });
  });
}

// FirestoreのDocumentSnapshotをモックするためのクラス
class MockDocumentSnapshot implements DocumentSnapshot {
  final String _id;
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic> data() => _data;

  // 他のDocumentSnapshotメソッドは実装しない（テストに必要ないため）
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
