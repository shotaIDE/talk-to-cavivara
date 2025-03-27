import 'package:cloud_firestore/cloud_firestore.dart';

class WorkLog {
  String id;
  String title;
  String? description;
  String icon; // アイコンフィールド（1文字の絵文字）
  DateTime createdAt;
  DateTime? completedAt;
  String createdBy;
  String? completedBy;
  bool isShared;
  bool isRecurring;
  int? recurringIntervalMs; // Store Duration in milliseconds
  bool isCompleted;
  int priority; // 優先度（数値が大きいほど優先度が高い）

  WorkLog({
    required this.id,
    required this.title,
    this.description,
    required this.icon, // アイコンパラメータ
    required this.createdAt,
    this.completedAt,
    required this.createdBy,
    this.completedBy,
    required this.isShared,
    required this.isRecurring,
    Duration? recurringInterval,
    this.isCompleted = false,
    this.priority = 0, // デフォルト優先度
  }) : recurringIntervalMs = recurringInterval?.inMilliseconds;

  Duration? get recurringInterval =>
      recurringIntervalMs != null
          ? Duration(milliseconds: recurringIntervalMs!)
          : null;

  void setRecurringInterval(Duration? value) {
    recurringIntervalMs = value?.inMilliseconds;
  }

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
      recurringInterval:
          data['recurringIntervalMs'] != null
              ? Duration(milliseconds: data['recurringIntervalMs'])
              : null,
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
