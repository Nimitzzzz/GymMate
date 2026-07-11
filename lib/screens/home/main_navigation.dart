import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import 'home_screen.dart';
import '../workout/workout_screen.dart';
import '../schedule/schedule_screen.dart';
import '../member/member_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/manage_schedule_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthService>().isAdmin;

    final List<Widget> pages = isAdmin
        ? const [ManageScheduleScreen(), MemberScreen(), ProfileScreen()]
        : const [
            HomeScreen(),
            WorkoutScreen(),
            ScheduleScreen(),
            ProfileScreen()
          ];

    final destinations = isAdmin
        ? const [
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, color: Colors.grey),
              selectedIcon:
                  Icon(Icons.calendar_month, color: AppColors.primary),
              label: 'Kelola Jadwal',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline, color: Colors.grey),
              selectedIcon: Icon(Icons.people, color: AppColors.primary),
              label: 'Kelola Member',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.grey),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Profil',
            ),
          ]
        : const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined, color: Colors.grey),
              selectedIcon:
                  Icon(Icons.fitness_center, color: AppColors.primary),
              label: 'Workout',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, color: Colors.grey),
              selectedIcon:
                  Icon(Icons.calendar_month, color: AppColors.primary),
              label: 'Jadwal',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.grey),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Profil',
            ),
          ];

    if (_currentIndex >= pages.length) _currentIndex = 0;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.dark,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        destinations: destinations,
      ),
    );
  }
}
