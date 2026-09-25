import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_language_provider.dart';
import '../../features/booking/screens/my_bookings_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../theme/app_theme.dart';

/// Main navigation shell containing the bottom navigation bar.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    required this.onLogout,
  });

  final Future<void> Function() onLogout;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<AppLanguageProvider>();

    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey(_currentIndex),
        child: [
          HomeScreen(
            onLogout: widget.onLogout,
            onViewBookings: () => setState(() => _currentIndex = 1),
          ),
          const MyBookingsScreen(),
          const ProfileScreen(),
        ][_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: langProvider.translate('nav_home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month_rounded),
              label: langProvider.translate('nav_bookings'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: langProvider.translate('nav_profile'),
            ),
          ],
        ),
      ),
    );
  }
}
