import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;
  
  String title;
  String? description;
  DateTime createdAt;
  DateTime? completedAt;
  String createdBy;
  String? completedBy;
  bool isShared;
  bool isRecurring;
  int priority; // 1: Low, 2: Medium, 3: High
  int? recurringIntervalMs; // Store Duration in milliseconds
  
  @Index()
  bool isCompleted;

  Task({
    required this.title,
    this.description,
    required this.createdAt,
    this.completedAt,
    required this.createdBy,
    this.completedBy,
    required this.isShared,
    required this.isRecurring,
    required this.priority,
    Duration? recurringInterval,
    this.isCompleted = false,
  }) : recurringIntervalMs = recurringInterval?.inMilliseconds;

  @ignore
  Duration? get recurringInterval => 
    recurringIntervalMs != null ? Duration(milliseconds: recurringIntervalMs!) : null;

  @ignore
  set recurringInterval(Duration? value) {
    recurringIntervalMs = value?.inMilliseconds;
  }
}
