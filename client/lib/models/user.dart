import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  String uid; // Firebase UID
  
  String name;
  String email;
  List<String> householdIds;
  DateTime createdAt;
  bool isPremium;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.householdIds,
    required this.createdAt,
    this.isPremium = false,
  });
}
