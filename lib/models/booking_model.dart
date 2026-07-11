import 'package:hive/hive.dart';

part 'booking_model.g.dart';

@HiveType(typeId: 3)
class BookingModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String scheduleId;

  @HiveField(2)
  String userEmail;

  @HiveField(3)
  DateTime bookingDate;

  BookingModel({
    required this.id,
    required this.scheduleId,
    required this.userEmail,
    required this.bookingDate,
  });
}
