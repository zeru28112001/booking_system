import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/services/auth_api_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/splash_screen.dart';

// ── DI wiring ─────────────────────────────────────────────────────────────────
// ApiClient → AuthApiService → AuthRepositoryImpl → AuthProvider

final _apiClient = ApiClient(
  baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api',
);

final _authApiService = AuthApiService(apiClient: _apiClient);

final _authRepositoryImpl = AuthRepositoryImpl(
  authApiService: _authApiService,
  apiClient: _apiClient,
  useMock: true, // ← set to false when real backend is ready
);

// ── Router ────────────────────────────────────────────────────────────────────

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (ctx, s) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (ctx, s) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (ctx, s) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'] ?? '';
        return OtpScreen(phone: phone);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (ctx, s) => const _PlaceholderHomeScreen(),
    ),
  ],
);

// ── Entry point ───────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const BookingApp());
}

class BookingApp extends StatelessWidget {
  const BookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: _authRepositoryImpl),
        ),
      ],
      child: MaterialApp.router(
        title: 'BookLocal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}

// ── Placeholder Home (Phase 2+) ───────────────────────────────────────────────

class _PlaceholderHomeScreen extends StatelessWidget {
  const _PlaceholderHomeScreen();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('BookLocal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.home_repair_service_rounded,
              size: 72,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Home — Phase 2 coming soon!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Consumer<AuthProvider>(
              builder: (context, a, w) => Text(
                'Logged in as ${a.currentUser?.name ?? 'Guest'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
