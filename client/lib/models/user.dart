import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const User._();

  const factory User({
    required String id,
    required String uid,
    required String name,
    required String email,
    required List<String> householdIds,
    required DateTime createdAt,
    @Default(false) bool isPremium,
  }) = _User;

  // Firestoreからのデータ変換
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      householdIds: List<String>.from(data['householdIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isPremium: data['isPremium'] ?? false,
    );
  }

  // FirestoreへのデータマッピングのためのMap
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'householdIds': householdIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPremium': isPremium,
    };
  }

  // JSONからの変換（オプション）
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
