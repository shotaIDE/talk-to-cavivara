import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_worker/models/work_log.dart';

void main() {
  group('WorkLog Model Tests', () {
    // テスト用のデータ
    final testId = 'test-id';
    final testTitle = 'テスト作業';
    final testDescription = 'これはテスト用の作業です';
    final testIcon = '🧹';
    final testCreatedAt = DateTime(2023, 1, 1);
    final testCompletedAt = DateTime(2023, 1, 2);
    final testCreatedBy = 'user-1';
    final testCompletedBy = 'user-2';
    final testIsShared = true;
    final testIsRecurring = true;
    final testRecurringIntervalMs = 86400000; // 1日
    final testIsCompleted = true;
    final testPriority = 2;

    test('WorkLogモデルが正しく作成されること', () {
      final workLog = WorkLog(
        id: testId,
        title: testTitle,
        description: testDescription,
        icon: testIcon,
        createdAt: testCreatedAt,
        completedAt: testCompletedAt,
        createdBy: testCreatedBy,
        completedBy: testCompletedBy,
        isShared: testIsShared,
        isRecurring: testIsRecurring,
        recurringIntervalMs: testRecurringIntervalMs,
        isCompleted: testIsCompleted,
        priority: testPriority,
      );

      expect(workLog.id, equals(testId));
      expect(workLog.title, equals(testTitle));
      expect(workLog.description, equals(testDescription));
      expect(workLog.icon, equals(testIcon));
      expect(workLog.createdAt, equals(testCreatedAt));
      expect(workLog.completedAt, equals(testCompletedAt));
      expect(workLog.createdBy, equals(testCreatedBy));
      expect(workLog.completedBy, equals(testCompletedBy));
      expect(workLog.isShared, equals(testIsShared));
      expect(workLog.isRecurring, equals(testIsRecurring));
      expect(workLog.recurringIntervalMs, equals(testRecurringIntervalMs));
      expect(workLog.isCompleted, equals(testIsCompleted));
      expect(workLog.priority, equals(testPriority));
    });

    test('デフォルト値が正しく設定されること', () {
      final workLog = WorkLog(
        id: testId,
        title: testTitle,
        icon: testIcon,
        createdAt: testCreatedAt,
        createdBy: testCreatedBy,
        isShared: testIsShared,
        isRecurring: testIsRecurring,
      );

      expect(workLog.isCompleted, equals(false)); // デフォルト値のテスト
      expect(workLog.priority, equals(0)); // デフォルト値のテスト
    });

    test('recurringInterval getterが正しく動作すること', () {
      final workLog = WorkLog(
        id: testId,
        title: testTitle,
        icon: testIcon,
        createdAt: testCreatedAt,
        createdBy: testCreatedBy,
        isShared: testIsShared,
        isRecurring: testIsRecurring,
        recurringIntervalMs: testRecurringIntervalMs,
      );

      expect(
        workLog.recurringInterval,
        equals(Duration(milliseconds: testRecurringIntervalMs)),
      );

      final workLogWithoutInterval = WorkLog(
        id: testId,
        title: testTitle,
        icon: testIcon,
        createdAt: testCreatedAt,
        createdBy: testCreatedBy,
        isShared: testIsShared,
        isRecurring: false,
      );

      expect(workLogWithoutInterval.recurringInterval, isNull);
    });

    test('toFirestore()が正しいMapを返すこと', () {
      final workLog = WorkLog(
        id: testId,
        title: testTitle,
        description: testDescription,
        icon: testIcon,
        createdAt: testCreatedAt,
        completedAt: testCompletedAt,
        createdBy: testCreatedBy,
        completedBy: testCompletedBy,
        isShared: testIsShared,
        isRecurring: testIsRecurring,
        recurringIntervalMs: testRecurringIntervalMs,
        isCompleted: testIsCompleted,
        priority: testPriority,
      );

      final firestoreMap = workLog.toFirestore();

      expect(firestoreMap['title'], equals(testTitle));
      expect(firestoreMap['description'], equals(testDescription));
      expect(firestoreMap['icon'], equals(testIcon));
      expect(firestoreMap['createdBy'], equals(testCreatedBy));
      expect(firestoreMap['completedBy'], equals(testCompletedBy));
      expect(firestoreMap['isShared'], equals(testIsShared));
      expect(firestoreMap['isRecurring'], equals(testIsRecurring));
      expect(
        firestoreMap['recurringIntervalMs'],
        equals(testRecurringIntervalMs),
      );
      expect(firestoreMap['isCompleted'], equals(testIsCompleted));
      expect(firestoreMap['priority'], equals(testPriority));
      expect(firestoreMap['createdAt'], isA<Timestamp>());
      expect(firestoreMap['completedAt'], isA<Timestamp>());
    });

    test('fromFirestore()が正しくWorkLogオブジェクトを作成すること', () {
      // Firestoreのドキュメントスナップショットをモック
      final mockData = {
        'title': testTitle,
        'description': testDescription,
        'icon': testIcon,
        'createdAt': Timestamp.fromDate(testCreatedAt),
        'completedAt': Timestamp.fromDate(testCompletedAt),
        'createdBy': testCreatedBy,
        'completedBy': testCompletedBy,
        'isShared': testIsShared,
        'isRecurring': testIsRecurring,
        'recurringIntervalMs': testRecurringIntervalMs,
        'isCompleted': testIsCompleted,
        'priority': testPriority,
      };

      final mockDocSnapshot = MockDocumentSnapshot(testId, mockData);

      final workLog = WorkLog.fromFirestore(mockDocSnapshot);

      expect(workLog.id, equals(testId));
      expect(workLog.title, equals(testTitle));
      expect(workLog.description, equals(testDescription));
      expect(workLog.icon, equals(testIcon));
      expect(workLog.createdAt, equals(testCreatedAt));
      expect(workLog.completedAt, equals(testCompletedAt));
      expect(workLog.createdBy, equals(testCreatedBy));
      expect(workLog.completedBy, equals(testCompletedBy));
      expect(workLog.isShared, equals(testIsShared));
      expect(workLog.isRecurring, equals(testIsRecurring));
      expect(workLog.recurringIntervalMs, equals(testRecurringIntervalMs));
      expect(workLog.isCompleted, equals(testIsCompleted));
      expect(workLog.priority, equals(testPriority));
    });

    test('fromFirestore()が欠損データに対してデフォルト値を設定すること', () {
      // 一部のフィールドが欠けているデータ
      final mockIncompleteData = {
        'title': testTitle,
        'createdAt': Timestamp.fromDate(testCreatedAt),
        'createdBy': testCreatedBy,
      };

      final mockDocSnapshot = MockDocumentSnapshot(testId, mockIncompleteData);

      final workLog = WorkLog.fromFirestore(mockDocSnapshot);

      expect(workLog.id, equals(testId));
      expect(workLog.title, equals(testTitle));
      expect(workLog.description, isNull);
      expect(workLog.icon, equals('🏠')); // デフォルトアイコン
      expect(workLog.createdAt, equals(testCreatedAt));
      expect(workLog.completedAt, isNull);
      expect(workLog.createdBy, equals(testCreatedBy));
      expect(workLog.completedBy, isNull);
      expect(workLog.isShared, equals(false));
      expect(workLog.isRecurring, equals(false));
      expect(workLog.recurringIntervalMs, isNull);
      expect(workLog.isCompleted, equals(false));
      expect(workLog.priority, equals(0));
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
