import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'work_log.freezed.dart';

@freezed
abstract class WorkLog with _$WorkLog {
  const WorkLog._();

  const factory WorkLog({
    required String id,
    required String title,
    String? description,
    required String icon,
    required DateTime createdAt,
    DateTime? completedAt,
    required String createdBy,
    String? completedBy,
    required bool isShared,
    required bool isRecurring,
    int? recurringIntervalMs,
    @Default(false) bool isCompleted,
    @Default(0) int priority,
  }) = _WorkLog;

  Duration? get recurringInterval =>
      recurringIntervalMs != null
          ? Duration(milliseconds: recurringIntervalMs!)
          : null;

  // Firestoreからのデータ変換
  factory WorkLog.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WorkLog(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      icon: data['icon'] ?? '🏠', // デフォルトアイコンを家の絵文字に設定
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt:
          data['completedAt'] != null
              ? (data['completedAt'] as Timestamp).toDate()
              : null,
      createdBy: data['createdBy'] ?? '',
      completedBy: data['completedBy'],
      isShared: data['isShared'] ?? false,
      isRecurring: data['isRecurring'] ?? false,
      recurringIntervalMs: data['recurringIntervalMs'],
      isCompleted: data['isCompleted'] ?? false,
      priority: data['priority'] ?? 0, // デフォルト優先度
    );
  }

  // FirestoreへのデータマッピングのためのMap
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'icon': icon, // アイコンフィールド
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdBy': createdBy,
      'completedBy': completedBy,
      'isShared': isShared,
      'isRecurring': isRecurring,
      'recurringIntervalMs': recurringIntervalMs,
      'isCompleted': isCompleted,
      'priority': priority, // 優先度フィールド
    };
  }
}
