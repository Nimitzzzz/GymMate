import 'package:hive/hive.dart';

part 'workout_model.g.dart';

@HiveType(typeId: 1)
class WorkoutModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userEmail;

  @HiveField(2)
  String exerciseName;

  @HiveField(3)
  int sets;

  @HiveField(4)
  int reps;

  @HiveField(5)
  double weight;

  @HiveField(6)
  DateTime date;

  @HiveField(7)
  String notes;

  WorkoutModel({
    required this.id,
    required this.userEmail,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.date,
    this.notes = '',
  });
}
