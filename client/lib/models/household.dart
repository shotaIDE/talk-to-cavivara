import 'package:isar/isar.dart';

part 'household.g.dart';

@collection
class Household {
  Id id = Isar.autoIncrement;
  
  String name;
  List<String> memberIds;
  DateTime createdAt;
  String createdBy;

  Household({
    required this.name,
    required this.memberIds,
    required this.createdAt,
    required this.createdBy,
  });
}
