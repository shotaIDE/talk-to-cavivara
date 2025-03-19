import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id; // Firestore ドキュメントID
  String uid; // Firebase UID
  String name;
  String email;
  List<String> householdIds;
  DateTime createdAt;
  bool isPremium;

  User({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.householdIds,
    required this.createdAt,
    this.isPremium = false,
  });

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
}
