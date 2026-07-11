import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String password;

  @HiveField(4, defaultValue: 'user')
  String role; // 'user' atau 'admin'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = 'user',
  });

  bool get isAdmin => role == 'admin';
}
