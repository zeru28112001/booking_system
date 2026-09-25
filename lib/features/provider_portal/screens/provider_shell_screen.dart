import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_language_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/provider_portal_provider.dart';
import 'provider_dashboard_screen.dart';
import 'provider_bookings_screen.dart';
import 'provider_services_screen.dart';
import 'provider_staff_screen.dart';
import 'provider_profile_screen.dart';

class ProviderShellScreen extends StatefulWidget {
  const ProviderShellScreen({super.key});

  @override
  State<ProviderShellScreen> createState() => _ProviderShellScreenState();
}

class _ProviderShellScreenState extends State<ProviderShellScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProviderPortalProvider>().fetchAllData();
      }
    });
  }

  final List<Widget> _screens = const [
    ProviderDashboardScreen(),
    ProviderBookingsScreen(),
    ProviderServicesScreen(),
    ProviderStaffScreen(),
    ProviderProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<AppLanguageProvider>();

    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey(_currentIndex),
        child: _screens[_currentIndex],
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
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard_rounded),
              label: langProvider.translate('provider_nav_dashboard'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_today_outlined),
              selectedIcon: const Icon(Icons.calendar_today_rounded),
              label: langProvider.translate('provider_nav_bookings'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.design_services_outlined),
              selectedIcon: const Icon(Icons.design_services_rounded),
              label: langProvider.translate('provider_nav_services'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline_rounded),
              selectedIcon: const Icon(Icons.people_rounded),
              label: langProvider.translate('provider_nav_staff'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: langProvider.translate('provider_nav_profile'),
            ),
          ],
        ),
      ),
    );
  }
}
