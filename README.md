# GymMate - Aplikasi Gym (Flutter)

Aplikasi manajemen gym sederhana untuk tugas Pemrograman Seluler. Dibangun dengan **Flutter** dan penyimpanan data lokal menggunakan **Hive**.

## Fitur
-  Login & Register (autentikasi lokal)
-  Workout Log — catat latihan (nama, set, reps, berat, tanggal, catatan) — CRUD penuh
-  Jadwal Kelas & Booking — lihat jadwal kelas gym dan booking/batalkan booking
-  Data Member & Membership — kelola data member (Basic/Premium/VIP) — CRUD penuh
-  Profil & Logout
-  Semua data tersimpan lokal di device menggunakan Hive (tanpa internet)

## Struktur Folder
```
lib/
├── main.dart
├── models/          # UserModel, WorkoutModel, ScheduleModel, BookingModel, MemberModel
├── services/        # HiveService (init & seed data), AuthService (Provider)
├── screens/
│   ├── auth/        # login_screen.dart, register_screen.dart
│   ├── home/        # main_navigation.dart (bottom nav), home_screen.dart (dashboard)
│   ├── workout/      # workout_screen.dart, add_edit_workout_screen.dart
│   ├── schedule/     # schedule_screen.dart
│   ├── member/       # member_screen.dart, add_edit_member_screen.dart
│   └── profile/      # profile_screen.dart
├── widgets/          # custom_textfield.dart, stat_card.dart
└── utils/            # app_theme.dart
```

---

## Cara Menjalankan (Step by Step di Android Studio)

### 1. Prasyarat
- Install **Flutter SDK** (flutter.dev) dan pastikan `flutter doctor` tidak ada error besar.
- Install **Android Studio** + plugin **Flutter** & **Dart** (Settings/Preferences → Plugins → cari "Flutter", install, restart).
- Siapkan emulator Android (AVD Manager) atau HP fisik dengan USB Debugging aktif.

### 2. Buka Project
1. Extract file zip project ini ke folder pilihanmu, misal `D:\Project\gym_app`.
2. Buka **Android Studio** → `File` → `Open` → pilih folder `gym_app`.
3. Karena folder `android/` dan `ios/` belum ada (project ini hanya berisi source code Dart), buka **Terminal** di Android Studio (bagian bawah) lalu jalankan:
   ```bash
   flutter create .
   ```
   Perintah ini akan men-generate folder `android/`, `ios/`, dll di dalam project **tanpa menimpa** folder `lib/` yang sudah ada.

### 3. Install Dependency
Di terminal, jalankan:
```bash
flutter pub get
```

### 4. Generate Kode Hive (Adapter)
Model (`UserModel`, `WorkoutModel`, dst) menggunakan anotasi `@HiveType` yang butuh file `.g.dart` hasil generate. Jalankan:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
Tunggu sampai selesai — ini akan membuat file seperti `user_model.g.dart`, `workout_model.g.dart`, dll di folder `lib/models/`.

> Jika nanti kamu mengubah model (menambah field baru), jalankan ulang perintah ini.

### 5. Jalankan Aplikasi
- Pilih device/emulator di pojok kanan atas Android Studio.
- Klik tombol **Run** (atau `Shift+F10`), atau via terminal:
  ```bash
  flutter run
  ```

