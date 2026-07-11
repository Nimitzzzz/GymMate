import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/schedule_model.dart';
import '../models/booking_model.dart';
import '../models/member_model.dart';

class HiveService {
  static const String userBox = 'users';
  static const String workoutBox = 'workouts';
  static const String scheduleBox = 'schedules';
  static const String bookingBox = 'bookings';
  static const String memberBox = 'members';
  static const String sessionBox = 'session';

  /// Inisialisasi Hive, daftarkan semua adapter, dan buka semua box.
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(WorkoutModelAdapter());
    Hive.registerAdapter(ScheduleModelAdapter());
    Hive.registerAdapter(BookingModelAdapter());
    Hive.registerAdapter(MemberModelAdapter());

    await Hive.openBox<UserModel>(userBox);
    await Hive.openBox<WorkoutModel>(workoutBox);
    await Hive.openBox<ScheduleModel>(scheduleBox);
    await Hive.openBox<BookingModel>(bookingBox);
    await Hive.openBox<MemberModel>(memberBox);
    await Hive.openBox(sessionBox); // box biasa utk simpan email user login

    await _seedInitialData();
  }

  /// Mengisi data awal (dummy) supaya aplikasi tidak kosong saat pertama dibuka.
  static Future<void> _seedInitialData() async {
    final userBoxRef = Hive.box<UserModel>(userBox);
    final adminExists = userBoxRef.values.any((u) => u.role == 'admin');
    if (!adminExists) {
      await userBoxRef.put(
        'admin-001',
        UserModel(
          id: 'admin-001',
          name: 'Super Admin',
          email: 'admin@gym.com',
          password: 'admin123',
          role: 'admin',
        ),
      );
    }
  }
}
