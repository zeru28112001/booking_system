import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:booking_system/core/network/api_client.dart';
import 'package:booking_system/features/provider/domain/entities/service.dart';
import 'package:booking_system/features/provider_portal/data/models/provider_profile_model.dart';
import 'package:booking_system/features/provider_portal/data/models/provider_staff_model.dart';
import 'package:booking_system/features/provider_portal/data/repositories/provider_portal_repository_impl.dart';
import 'package:booking_system/features/provider_portal/data/services/provider_portal_api_service.dart';
import 'package:booking_system/features/provider_portal/domain/entities/provider_staff.dart';
import 'package:booking_system/features/provider_portal/providers/provider_portal_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 7 & 8 - Provider Portal Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ProviderProfileModel JSON serialization & deserialization', () {
      const profile = ProviderProfileModel(
        id: 'prov_001',
        shopName: 'Glow Salon',
        categoryName: 'Beauty & Salon',
        description: 'Quality hair and nails',
        address: 'Yangon',
        phone: '09 123 456',
        isAvailable: true,
        verificationStatus: 'verified',
        rating: 4.9,
        reviewCount: 20,
        imageUrl: 'http://img.jpg',
      );

      final json = profile.toJson();
      expect(json['shop_name'], 'Glow Salon');
      expect(json['is_available'], true);

      final decoded = ProviderProfileModel.fromJson(json);
      expect(decoded.shopName, 'Glow Salon');
      expect(decoded.rating, 4.9);
    });

    test('ProviderStaffModel JSON serialization & deserialization', () {
      const staff = ProviderStaffModel(
        id: 'stf_1',
        name: 'Aye Aye Win',
        phone: '09 111 222',
        specialties: ['Haircut', 'Color'],
        isActive: true,
        avatarUrl: '',
      );

      final json = staff.toJson();
      expect(json['name'], 'Aye Aye Win');
      expect(json['specialties'], contains('Haircut'));

      final decoded = ProviderStaffModel.fromJson(json);
      expect(decoded.name, 'Aye Aye Win');
      expect(decoded.specialties.length, 2);
    });

    test('ProviderPortalRepositoryImpl services and staff CRUD', () async {
      final repo = ProviderPortalRepositoryImpl(
        providerPortalApiService: ProviderPortalApiService(
          apiClient: ApiClient(baseUrl: 'http://localhost'),
        ),
      );

      final initialServices = await repo.getServices();
      expect(initialServices, isNotEmpty);

      final newService = await repo.addService(
        const Service(
          id: '',
          name: 'Spa Treatment',
          group: 'Spa',
          price: 30000,
          durationMinutes: 60,
        ),
      );

      expect(newService.name, 'Spa Treatment');
      final updatedServices = await repo.getServices();
      expect(updatedServices.first.name, 'Spa Treatment');

      final initialStaff = await repo.getStaff();
      expect(initialStaff, isNotEmpty);

      final newStaff = await repo.addStaff(
        const ProviderStaff(
          id: '',
          name: 'Nilar',
          phone: '09 999 888',
          specialties: ['Massage'],
          isActive: true,
          avatarUrl: '',
        ),
      );

      expect(newStaff.name, 'Nilar');
      final updatedStaff = await repo.getStaff();
      expect(updatedStaff.first.name, 'Nilar');
    });

    test('ProviderPortalProvider state transitions & revenue', () async {
      final repo = ProviderPortalRepositoryImpl(
        providerPortalApiService: ProviderPortalApiService(
          apiClient: ApiClient(baseUrl: 'http://localhost'),
        ),
      );
      final provider = ProviderPortalProvider(providerPortalRepository: repo);

      await provider.fetchAllData();
      expect(provider.profile, isNotNull);
      expect(provider.services, isNotEmpty);
      expect(provider.staff, isNotEmpty);
      expect(provider.schedule, isNotNull);
      expect(provider.bookings, isNotEmpty);

      // Verify availability toggle
      expect(provider.isAvailable, true);
      await provider.toggleAvailability(false);
      expect(provider.isAvailable, false);

      // Verify booking status transition (Accept pending booking)
      final pending = provider.pendingBookings.first;
      final success = await provider.updateBookingStatus(pending.id, 'accepted');
      expect(success, true);
      expect(provider.pendingBookings.any((b) => b.id == pending.id), false);
    });
  });
}
