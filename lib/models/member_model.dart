import 'package:hive/hive.dart';

part 'member_model.g.dart';

@HiveType(typeId: 4)
class MemberModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String membershipType; // Basic, Premium, VIP

  @HiveField(4)
  DateTime joinDate;

  @HiveField(5)
  DateTime expiryDate;

  MemberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.membershipType,
    required this.joinDate,
    required this.expiryDate,
  });

  bool get isActive => expiryDate.isAfter(DateTime.now());
}
