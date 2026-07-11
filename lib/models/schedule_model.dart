import 'package:hive/hive.dart';

part 'schedule_model.g.dart';

@HiveType(typeId: 2)
class ScheduleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String className;

  @HiveField(2)
  String trainer;

  @HiveField(3)
  String day;

  @HiveField(4)
  String time;

  @HiveField(5)
  int quota;

  @HiveField(6)
  int bookedCount;

  ScheduleModel({
    required this.id,
    required this.className,
    required this.trainer,
    required this.day,
    required this.time,
    required this.quota,
    this.bookedCount = 0,
  });

  bool get isFull => bookedCount >= quota;
}
