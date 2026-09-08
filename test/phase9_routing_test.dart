import 'package:flutter_test/flutter_test.dart';

import 'package:booking_system/core/network/api_client.dart';
import 'package:booking_system/features/auth/data/models/user_model.dart';
import 'package:booking_system/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:booking_system/features/auth/data/services/auth_api_service.dart';
import 'package:booking_system/features/auth/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 9 - Routing & Role Architecture Tests', () {
    test('User role parsing and role checks', () {
      const customer = UserModel(
        id: 'u1',
        name: 'Aung Aung',
        phone: '09 111 222',
        role: 'customer',
        token: 'token1',
      );

      const provider = UserModel(
        id: 'u2',
        name: 'Glow Salon',
        phone: '09 333 444',
        role: 'provider',
        token: 'token2',
      );

      expect(customer.role, 'customer');
      expect(provider.role, 'provider');
    });

    test('AuthProvider register with role', () async {
      final apiClient = ApiClient(baseUrl: 'http://localhost');
      final authRepo = AuthRepositoryImpl(
        authApiService: AuthApiService(apiClient: apiClient),
        apiClient: apiClient,
      );
      final authProvider = AuthProvider(authRepository: authRepo);

      await authProvider.register(
        name: 'Provider Business',
        phone: '09 999 888',
        password: 'password123',
        role: 'provider',
      );

      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser?.role, 'provider');
    });
  });
}
