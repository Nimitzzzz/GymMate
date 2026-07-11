import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/schedule_model.dart';
import '../../models/booking_model.dart';
import '../../services/hive_service.dart';
import '../../utils/app_theme.dart';
import 'add_edit_schedule_screen.dart';

class ManageScheduleScreen extends StatelessWidget {
  const ManageScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ScheduleModel>(HiveService.scheduleBox);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Jadwal Kelas')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditScheduleScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<ScheduleModel> b, _) {
          final schedules = b.values.toList();

          if (schedules.isEmpty) {
            return Center(
              child: Text('Belum ada jadwal kelas.',
                  style: TextStyle(color: Colors.grey.shade600)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final s = schedules[index];
              return Dismissible(
                key: Key(s.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  final bookingBox =
                      Hive.box<BookingModel>(HiveService.bookingBox);
                  final related = bookingBox.values
                      .where((bk) => bk.scheduleId == s.id)
                      .toList();
                  for (final bk in related) {
                    await bk.delete();
                  }
                  await s.delete();
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.calendar_month, color: Colors.white),
                    ),
                    title: Text(s.className,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Pelatih: ${s.trainer}\n${s.day}, ${s.time} • Kuota ${s.bookedCount}/${s.quota}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.edit, size: 18),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                AddEditScheduleScreen(existingSchedule: s)),
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
