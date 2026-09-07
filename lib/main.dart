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
import 'features/booking/data/repositories/booking_repository_impl.dart';
import 'features/booking/data/services/booking_api_service.dart';
import 'features/booking/providers/booking_provider.dart';
import 'features/booking/screens/booking_confirmation_screen.dart';
import 'features/booking/screens/booking_detail_screen.dart';
import 'features/booking/screens/my_bookings_screen.dart';
import 'features/booking/widgets/booking_form_sheet.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/data/services/home_api_service.dart';
import 'features/home/providers/home_provider.dart';
import 'features/provider/data/repositories/provider_repository_impl.dart';
import 'features/provider/data/services/provider_api_service.dart';
import 'features/provider/providers/provider_detail_provider.dart';
import 'features/provider/providers/provider_list_provider.dart';
import 'features/provider/screens/provider_detail_screen.dart';
import 'features/provider/screens/provider_list_screen.dart';

import 'core/widgets/main_shell_screen.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/data/services/profile_api_service.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/settings_screen.dart';
import 'features/review/data/repositories/review_repository_impl.dart';
import 'features/review/data/services/review_api_service.dart';
import 'features/review/providers/review_provider.dart';
import 'features/review/widgets/review_form_sheet.dart';

import 'features/provider_portal/data/repositories/provider_portal_repository_impl.dart';
import 'features/provider_portal/data/services/provider_portal_api_service.dart';
import 'features/provider_portal/providers/provider_portal_provider.dart';
import 'features/provider_portal/screens/provider_earnings_screen.dart';
import 'features/provider_portal/screens/provider_onboarding_screen.dart';
import 'features/provider_portal/screens/provider_schedule_screen.dart';
import 'features/provider_portal/screens/provider_shell_screen.dart';

import 'features/admin_portal/providers/admin_portal_provider.dart';
import 'features/admin_portal/screens/admin_shell_screen.dart';

// ── DI wiring ─────────────────────────────────────────────────────────────────
// ApiClient → *ApiService → *RepositoryImpl → *Provider

final _apiClient = ApiClient(
  baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api',
);

final _authApiService = AuthApiService(apiClient: _apiClient);

final _authRepositoryImpl = AuthRepositoryImpl(
  authApiService: _authApiService,
  apiClient: _apiClient,
  useMock: true, // ← set to false when real backend is ready
);

final _homeApiService = HomeApiService(apiClient: _apiClient);

final _homeRepositoryImpl = HomeRepositoryImpl(
  homeApiService: _homeApiService,
  useMock: true, // ← set to false when GET /categories is ready
);

final _providerApiService = ProviderApiService(apiClient: _apiClient);

final _providerRepositoryImpl = ProviderRepositoryImpl(
  providerApiService: _providerApiService,
  useMock: true, // ← set to false when provider endpoints are ready
);

final _bookingApiService = BookingApiService(apiClient: _apiClient);

final _bookingRepositoryImpl = BookingRepositoryImpl(
  bookingApiService: _bookingApiService,
  useMock: true, // ← set to false when booking endpoints are ready
);

final _reviewApiService = ReviewApiService(apiClient: _apiClient);

final _reviewRepositoryImpl = ReviewRepositoryImpl(
  reviewApiService: _reviewApiService,
  useMock: true,
);

final _profileApiService = ProfileApiService(apiClient: _apiClient);

final _profileRepositoryImpl = ProfileRepositoryImpl(
  profileApiService: _profileApiService,
  useMock: true,
);

final _providerPortalApiService = ProviderPortalApiService(apiClient: _apiClient);

final _providerPortalRepositoryImpl = ProviderPortalRepositoryImpl(
  providerPortalApiService: _providerPortalApiService,
  useMock: true,
);

// ── Router ────────────────────────────────────────────────────────────────────

final GoRouter _router = GoRouter(
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
      builder: (context, state) {
        final auth = context.read<AuthProvider>();
        return MainShellScreen(
          onLogout: () async {
            await auth.logout();
            _router.go('/login');
          },
        );
      },
    ),
    GoRoute(
      path: '/category/:id',
      builder: (context, state) => ProviderListScreen(
        categoryId: state.pathParameters['id'] ?? '',
        categoryName: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/provider/:id',
      builder: (context, state) => ProviderDetailScreen(
        providerId: state.pathParameters['id'] ?? '',
        providerName: state.uri.queryParameters['name'] ?? '',
        // Cross-feature glue: provider entities → booking primitives, so
        // features/booking never imports features/provider.
        onBook: (provider, servicesList, staff) async {
          final serviceIds = servicesList.map((s) => s.id).join(', ');
          final serviceName = servicesList.map((s) => s.name).join(' + ');
          final totalPrice =
              servicesList.fold(0, (sum, s) => sum + s.price);
          final totalDuration =
              servicesList.fold(0, (sum, s) => sum + s.durationMinutes);
          final itemized = servicesList.map((s) => s.name).toList();

          final bookingId = await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => BookingFormSheet(
              providerId: provider.id,
              providerName: provider.name,
              serviceId: serviceIds,
              serviceName: serviceName,
              price: totalPrice,
              durationMinutes: totalDuration,
              staffId: staff?.id,
              staffName: staff?.name,
              isHomeService: provider.isHomeService,
              providerAddress: provider.address,
              itemizedServices: itemized,
            ),
          );
          // The sheet's context is gone after the await — route globally.
          if (bookingId != null) {
            _router.push('/booking-confirmation/$bookingId');
          }
        },
      ),
    ),
    GoRoute(
      path: '/bookings',
      builder: (context, state) => const MyBookingsScreen(),
    ),
    GoRoute(
      path: '/booking/:id',
      builder: (context, state) => BookingDetailScreen(
        bookingId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/booking-confirmation/:id',
      builder: (context, state) => BookingConfirmationScreen(
        bookingId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/provider-dashboard',
      builder: (context, state) => const ProviderShellScreen(),
    ),
    GoRoute(
      path: '/provider-onboarding',
      builder: (context, state) => const ProviderOnboardingScreen(),
    ),
    GoRoute(
      path: '/provider-schedule',
      builder: (context, state) => const ProviderScheduleScreen(),
    ),
    GoRoute(
      path: '/provider-earnings',
      builder: (context, state) => const ProviderEarningsScreen(),
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminShellScreen(),
    ),
    GoRoute(
      path: '/write-review/:providerId',
      builder: (context, state) {
        final providerId = state.pathParameters['providerId'] ?? '';
        final providerName = state.uri.queryParameters['name'] ?? 'Provider';
        final bookingId = state.uri.queryParameters['bookingId'];
        return Scaffold(
          body: Builder(
            builder: (ctx) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                final submitted = await showModalBottomSheet<bool>(
                  context: ctx,
                  isScrollControlled: true,
                  builder: (_) => ReviewFormSheet(
                    providerId: providerId,
                    providerName: providerName,
                    bookingId: bookingId,
                  ),
                );
                if (ctx.mounted) {
                  if (submitted == true) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Review submitted! Thank you.')),
                    );
                  }
                  _router.pop();
                }
              });
              return const SizedBox.shrink();
            },
          ),
        );
      },
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
        ChangeNotifierProvider(
          create: (_) => HomeProvider(homeRepository: _homeRepositoryImpl),
        ),
        ChangeNotifierProvider(
          create: (_) => ProviderListProvider(
            providerRepository: _providerRepositoryImpl,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProviderDetailProvider(
            providerRepository: _providerRepositoryImpl,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(
            bookingRepository: _bookingRepositoryImpl,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ReviewProvider(
            reviewRepository: _reviewRepositoryImpl,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            profileRepository: _profileRepositoryImpl,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProviderPortalProvider(
            providerPortalRepository: _providerPortalRepositoryImpl,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminPortalProvider(),
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
