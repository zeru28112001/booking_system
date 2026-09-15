import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/maintenance_provider.dart';
import '../../../../features/home/data/services/home_api_service.dart';
import '../providers/auth_provider.dart';
import 'maintenance_screen.dart';

/// Splash screen: animated logo → checks auth token → routes to Home or Login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.durationSlow,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(AppConstants.splashDelay);
    if (!mounted) return;

    // Check maintenance mode BEFORE auth (no token needed)
    try {
      final homeService = context.read<HomeApiService>();
      final settings = await homeService.getPublicSettings();
      final isMaintenance = settings['isMaintenanceMode'] as bool? ?? false;

      if (isMaintenance && mounted) {
        // Admins still get through; everyone else sees the maintenance page
        final auth = context.read<AuthProvider>();
        await auth.checkAuthState();
        if (!mounted) return;
        if (auth.currentUser?.role == 'admin') {
          context.go('/admin-dashboard');
          return;
        }
        // Set initial state in provider so the overlay also activates
        context.read<MaintenanceProvider>().setInitial(true);
        // Non-admin: push maintenance screen (overlay handles future changes too)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MaintenanceScreen()),
        );
        return;
      }
    } catch (_) {
      // If settings fetch fails, proceed normally
    }

    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.checkAuthState();
    if (!mounted) return;
    if (auth.isAuthenticated) {
      final role = auth.currentUser?.role ?? 'customer';
      if (role == 'admin') {
        context.go('/admin-dashboard');
      } else if (role == 'provider') {
        context.go('/provider-dashboard');
      } else {
        context.go('/home');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App logo mark
                SizedBox(
                  height: 160,
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                Text(
                  'Local services at your fingertips',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: AppConstants.spaceXxl),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
