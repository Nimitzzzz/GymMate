import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import 'hive_service.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  bool get isAdmin => _currentUser?.role == 'admin';

  Box<UserModel> get _userBox => Hive.box<UserModel>(HiveService.userBox);

  Box get _sessionBox => Hive.box(HiveService.sessionBox);

  AuthService() {
    _restoreSession();
  }

  /// Cek apakah ada sesi login tersimpan sebelumnya.
  void _restoreSession() {
    final savedEmail = _sessionBox.get('currentUserEmail');
    if (savedEmail != null) {
      final user = _userBox.values.where((u) => u.email == savedEmail);
      if (user.isNotEmpty) {
        _currentUser = user.first;
      }
    }
  }

  /// Registrasi user baru. Mengembalikan null jika sukses, atau pesan error.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final emailExists =
        _userBox.values.any((u) => u.email == email.trim().toLowerCase());
    if (emailExists) {
      return 'Email sudah terdaftar, silakan login.';
    }
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      return 'Semua data wajib diisi.';
    }
    if (password.length < 6) {
      return 'Password minimal 6 karakter.';
    }

    final user = UserModel(
      id: const Uuid().v4(),
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
    );
    await _userBox.put(user.id, user);
    return null; // sukses
  }

  /// Login user. Mengembalikan null jika sukses, atau pesan error.
  Future<String?> login(
      {required String email, required String password}) async {
    final matches = _userBox.values.where(
      (u) => u.email == email.trim().toLowerCase() && u.password == password,
    );

    if (matches.isEmpty) {
      return 'Email atau password salah.';
    }

    _currentUser = matches.first;
    await _sessionBox.put('currentUserEmail', _currentUser!.email);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _sessionBox.delete('currentUserEmail');
    notifyListeners();
  }
}
