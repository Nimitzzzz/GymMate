import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/schedule_model.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/hive_service.dart';
import '../../utils/app_theme.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = context.watch<AuthService>().currentUser?.email ?? '';
    final scheduleBox = Hive.box<ScheduleModel>(HiveService.scheduleBox);
    final bookingBox = Hive.box<BookingModel>(HiveService.bookingBox);

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Kelas')),
      body: ValueListenableBuilder(
        valueListenable: scheduleBox.listenable(),
        builder: (context, Box<ScheduleModel> sBox, _) {
          return ValueListenableBuilder(
            valueListenable: bookingBox.listenable(),
            builder: (context, Box<BookingModel> bBox, _) {
              final schedules = sBox.values.toList();
              final myBookings = bBox.values.where((b) => b.userEmail == userEmail).toList();

              bool isBooked(String scheduleId) =>
                  myBookings.any((b) => b.scheduleId == scheduleId);

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final s = schedules[index];
                  final booked = isBooked(s.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  s.className,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: s.isFull
                                      ? AppColors.danger.withOpacity(0.15)
                                      : AppColors.success.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  s.isFull ? 'Penuh' : '${s.quota - s.bookedCount} slot',
                                  style: TextStyle(
                                    color: s.isFull ? AppColors.danger : AppColors.success,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 6),
                              Text('Pelatih: ${s.trainer}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 6),
                              Text('${s.day}, ${s.time}'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: booked ? Colors.grey.shade400 : AppColors.primary,
                              ),
                              onPressed: (booked || (s.isFull && !booked))
                                  ? (booked
                                      ? () async {
                                          final myBooking = myBookings
                                              .firstWhere((b) => b.scheduleId == s.id);
                                          await myBooking.delete();
                                          s.bookedCount -= 1;
                                          await s.save();
                                        }
                                      : null)
                                  : () async {
                                      final newBooking = BookingModel(
                                        id: const Uuid().v4(),
                                        scheduleId: s.id,
                                        userEmail: userEmail,
                                        bookingDate: DateTime.now(),
                                      );
                                      await bookingBox.put(newBooking.id, newBooking);
                                      s.bookedCount += 1;
                                      await s.save();
                                    },
                              child: Text(booked
                                  ? 'Batalkan Booking'
                                  : (s.isFull ? 'Kelas Penuh' : 'Booking Kelas')),
                            ),
                          ),
                        ],
                      ),
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
