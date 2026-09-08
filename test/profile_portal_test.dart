import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:booking_system/core/network/api_client.dart';
import 'package:booking_system/features/admin_portal/providers/admin_portal_provider.dart';
import 'package:booking_system/features/provider_portal/data/repositories/provider_portal_repository_impl.dart';
import 'package:booking_system/features/provider_portal/data/services/provider_portal_api_service.dart';
import 'package:booking_system/features/provider_portal/domain/entities/provider_profile.dart';
import 'package:booking_system/features/provider_portal/providers/provider_portal_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Provider Profile & Admin Profile Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ProviderPortalProvider update shop profile', () async {
      final repo = ProviderPortalRepositoryImpl(
        providerPortalApiService: ProviderPortalApiService(
          apiClient: ApiClient(baseUrl: 'http://localhost'),
        ),
      );
      final provider = ProviderPortalProvider(providerPortalRepository: repo);
      await provider.fetchAllData();

      expect(provider.profile, isNotNull);
      final originalName = provider.profile!.shopName;

      const updated = ProviderProfile(
        id: 'prov_001',
        shopName: 'Glow Beauty & Nail Spa',
        categoryName: 'Beauty & Salon',
        description: 'Updated description for testing.',
        address: 'No. 99, Pyay Rd, Yangon',
        phone: '09 111 222 333',
        isAvailable: true,
        verificationStatus: 'verified',
        rating: 4.9,
        reviewCount: 30,
        imageUrl: '',
      );

      final success = await provider.updateProfile(updated);
      expect(success, true);
      expect(provider.profile?.shopName, 'Glow Beauty & Nail Spa');
      expect(provider.profile?.shopName, isNot(originalName));
      expect(provider.profile?.address, 'No. 99, Pyay Rd, Yangon');
    });

    test('AdminPortalProvider profile & metrics information', () {
      final adminProvider = AdminPortalProvider();
      final metrics = adminProvider.metrics;

      expect(metrics['total_users'], greaterThan(0));
      expect(metrics['total_providers'], greaterThan(0));
      expect(metrics['pending_verifications'], isNotNull);
      expect(adminProvider.totalCustomersCount, 148);
    });
  });
}
