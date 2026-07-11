import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/workout_model.dart';
import '../../services/auth_service.dart';
import '../../services/hive_service.dart';
import '../../utils/app_theme.dart';
import 'add_edit_workout_screen.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = context.watch<AuthService>().currentUser?.email ?? '';
    final box = Hive.box<WorkoutModel>(HiveService.workoutBox);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Log')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditWorkoutScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<WorkoutModel> b, _) {
          final myWorkouts = b.values.where((w) => w.userEmail == userEmail).toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (myWorkouts.isEmpty) {
            return Center(
              child: Text(
                'Belum ada catatan latihan.\nTekan tombol + untuk menambah.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myWorkouts.length,
            itemBuilder: (context, index) {
              final w = myWorkouts[index];
              return Dismissible(
                key: Key(w.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => w.delete(),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.fitness_center, color: Colors.white),
                    ),
                    title: Text(w.exerciseName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${w.sets} set x ${w.reps} reps • ${w.weight} kg\n${w.date.day}/${w.date.month}/${w.date.year}'
                      '${w.notes.isNotEmpty ? '\nCatatan: ${w.notes}' : ''}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.edit, size: 18),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditWorkoutScreen(existingWorkout: w),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
