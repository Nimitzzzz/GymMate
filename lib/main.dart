import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/hive_service.dart';
import 'services/auth_service.dart';
import 'utils/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const GymApp());
}

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'GymMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: Consumer<AuthService>(
          builder: (context, auth, _) {
            return auth.isLoggedIn
                ? const MainNavigation()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
