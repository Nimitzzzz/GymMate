import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/workout_model.dart';
import '../../models/schedule_model.dart';
import '../../models/member_model.dart';
import '../../services/auth_service.dart';
import '../../services/hive_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final userEmail = auth.currentUser?.email ?? '';
    final userName = auth.currentUser?.name ?? 'Gymers';

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<WorkoutModel>(HiveService.workoutBox).listenable(),
        builder: (context, Box<WorkoutModel> workoutBox, _) {
          final myWorkouts =
              workoutBox.values.where((w) => w.userEmail == userEmail).toList();
          final totalSets = myWorkouts.fold<int>(0, (sum, w) => sum + w.sets);

          return ValueListenableBuilder(
            valueListenable: Hive.box<ScheduleModel>(HiveService.scheduleBox).listenable(),
            builder: (context, Box<ScheduleModel> scheduleBox, _) {
              return ValueListenableBuilder(
                valueListenable: Hive.box<MemberModel>(HiveService.memberBox).listenable(),
                builder: (context, Box<MemberModel> memberBox, _) {
                  final activeMembers =
                      memberBox.values.where((m) => m.isActive).length;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $userName 👋',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Semangat latihan hari ini!',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 24),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.3,
                          children: [
                            StatCard(
                              title: 'Total Workout Log',
                              value: '${myWorkouts.length}',
                              icon: Icons.fitness_center,
                              color: AppColors.primary,
                            ),
                            StatCard(
                              title: 'Total Set Latihan',
                              value: '$totalSets',
                              icon: Icons.repeat,
                              color: Colors.blueAccent,
                            ),
                            StatCard(
                              title: 'Kelas Tersedia',
                              value: '${scheduleBox.length}',
                              icon: Icons.calendar_month,
                              color: Colors.teal,
                            ),
                            StatCard(
                              title: 'Member Aktif',
                              value: '$activeMembers',
                              icon: Icons.people,
                              color: Colors.deepPurple,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Latihan Terbaru',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (myWorkouts.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Belum ada catatan latihan. Yuk mulai tambahkan di tab Workout!',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          )
                        else
                          ...myWorkouts.reversed.take(3).map(
                                (w) => Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: AppColors.primary,
                                      child: Icon(Icons.fitness_center, color: Colors.white, size: 18),
                                    ),
                                    title: Text(w.exerciseName),
                                    subtitle: Text('${w.sets} set x ${w.reps} reps • ${w.weight} kg'),
                                    trailing: Text(
                                      '${w.date.day}/${w.date.month}',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
