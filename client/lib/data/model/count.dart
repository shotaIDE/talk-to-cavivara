import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'count.freezed.dart';

/// カウント
///
/// カウンターの状態を保持する
@freezed
abstract class Count with _$Count {
  const factory Count({
    required String id,
    required int count,
    required DateTime updatedAt,
  }) = _Count;

  const Count._();

  factory Count.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Count(
      id: doc.id,
      count: data['count'] as int,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'count': count,
      // `DateTime` インスタンスはそのままFirestoreに渡すことで、Firestore側でタイムスタンプ型として保持させる
      'createdAt': updatedAt,
    };
  }
}
