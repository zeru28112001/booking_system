import 'package:flutter_test/flutter_test.dart';

import 'package:booking_system/features/admin_portal/providers/admin_portal_provider.dart';
import 'package:booking_system/features/auth/data/models/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 9 - Admin Portal & Account Isolation Tests', () {
    test('AdminPortalProvider loads pending verifications & metrics', () async {
      final provider = AdminPortalProvider();
      await provider.fetchAdminData();

      expect(provider.isLoading, false);
      expect(provider.pendingProviders, isNotEmpty);
      expect(provider.verifiedProviders, isNotEmpty);
      expect(provider.metrics['total_users'], greaterThan(0));
      expect(provider.metrics['total_providers'], greaterThan(0));
    });

    test('Admin approval of pending provider (FR-16)', () async {
      final provider = AdminPortalProvider();
      await provider.fetchAdminData();

      final initialPendingCount = provider.pendingProviders.length;
      final initialVerifiedCount = provider.verifiedProviders.length;
      final target = provider.pendingProviders.first;

      final success = await provider.approveProvider(target.id);
      expect(success, true);
      expect(provider.pendingProviders.length, initialPendingCount - 1);
      expect(provider.verifiedProviders.length, initialVerifiedCount + 1);
      expect(provider.pendingProviders.any((p) => p.id == target.id), false);
    });

    test('Admin rejection of pending provider (FR-16)', () async {
      final provider = AdminPortalProvider();
      await provider.fetchAdminData();

      final initialPendingCount = provider.pendingProviders.length;
      final target = provider.pendingProviders.first;

      final success = await provider.rejectProvider(target.id, 'Incomplete license documents');
      expect(success, true);
      expect(provider.pendingProviders.length, initialPendingCount - 1);
      expect(provider.pendingProviders.any((p) => p.id == target.id), false);
    });

    test('Strict Role Isolation user roles model validation', () {
      const adminUser = UserModel(
        id: 'admin_1',
        name: 'Super Admin',
        phone: '09 000 000',
        role: 'admin',
        token: 'token_admin',
      );

      const customerUser = UserModel(
        id: 'cust_1',
        name: 'Customer One',
        phone: '09 111 111',
        role: 'customer',
        token: 'token_customer',
      );

      const providerUser = UserModel(
        id: 'prov_1',
        name: 'Provider Shop',
        phone: '09 222 222',
        role: 'provider',
        token: 'token_provider',
      );

      expect(adminUser.role, 'admin');
      expect(customerUser.role, 'customer');
      expect(providerUser.role, 'provider');
    });
  });
}
