import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:booking_system/features/profile/data/models/profile_model.dart';
import 'package:booking_system/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:booking_system/features/profile/data/services/profile_api_service.dart';
import 'package:booking_system/features/profile/providers/profile_provider.dart';
import 'package:booking_system/features/review/data/models/review_model.dart';
import 'package:booking_system/features/review/data/repositories/review_repository_impl.dart';
import 'package:booking_system/features/review/data/services/review_api_service.dart';
import 'package:booking_system/features/review/providers/review_provider.dart';
import 'package:booking_system/core/network/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 5 - Review & Rating Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ReviewModel serialization & deserialization', () {
      final model = ReviewModel(
        id: 'rev_1',
        providerId: 'prov_1',
        authorName: 'Aung Aung',
        rating: 5.0,
        comment: 'Excellent service!',
        date: '2026-09-07',
      );

      final json = model.toJson();
      expect(json['id'], 'rev_1');
      expect(json['rating'], 5.0);

      final decoded = ReviewModel.fromJson(json);
      expect(decoded.id, 'rev_1');
      expect(decoded.authorName, 'Aung Aung');
      expect(decoded.rating, 5.0);
    });

    test('ReviewRepositoryImpl submit & retrieve reviews', () async {
      final repo = ReviewRepositoryImpl(
        reviewApiService: ReviewApiService(
          apiClient: ApiClient(baseUrl: 'http://localhost'),
        ),
      );

      final submitted = await repo.submitReview(
        providerId: 'p1',
        rating: 4.5,
        comment: 'Great work',
        authorName: 'Tester',
      );

      expect(submitted.providerId, 'p1');
      expect(submitted.rating, 4.5);

      final list = await repo.getProviderReviews('p1');
      expect(list.length, equals(1));
      expect(list.first.comment, 'Great work');
    });

    test('ReviewProvider state management', () async {
      final repo = ReviewRepositoryImpl(
        reviewApiService: ReviewApiService(
          apiClient: ApiClient(baseUrl: 'http://localhost'),
        ),
      );
      final provider = ReviewProvider(reviewRepository: repo);

      expect(provider.reviews, isEmpty);
      expect(provider.isLoading, false);

      final review = await provider.submitReview(
        providerId: 'p2',
        rating: 5.0,
        comment: 'Superb',
      );

      expect(review, isNotNull);
      expect(provider.reviews.length, 1);
      expect(provider.isSubmitting, false);
    });
  });

  group('Phase 6 - Profile & Settings Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ProfileModel serialization & deserialization', () {
      const profile = ProfileModel(
        id: 'usr_001',
        name: 'Khin Su Su',
        phone: '09 987 654 321',
        email: 'khinsusu@gmail.com',
        notificationsEnabled: true,
        language: 'English',
      );

      final json = profile.toJson();
      expect(json['id'], 'usr_001');
      expect(json['name'], 'Khin Su Su');

      final decoded = ProfileModel.fromJson(json);
      expect(decoded.name, 'Khin Su Su');
      expect(decoded.notificationsEnabled, true);
    });

    test('ProfileRepositoryImpl fetch and update profile', () async {
      final repo = ProfileRepositoryImpl(
        profileApiService: ProfileApiService(
          apiClient: ApiClient(baseUrl: 'http://localhost'),
        ),
      );

      final initial = await repo.getProfile();
      expect(initial.name, 'Khin Su Su');

      final updated = await repo.updateProfile(
        name: 'Su Su Khin',
        email: 'susu@gmail.com',
      );

      expect(updated.name, 'Su Su Khin');
      expect(updated.email, 'susu@gmail.com');
    });

    test('ProfileProvider fetch and update preferences', () async {
      final repo = ProfileRepositoryImpl(
        profileApiService: ProfileApiService(
          apiClient: ApiClient(baseUrl: 'http://localhost'),
        ),
      );
      final provider = ProfileProvider(profileRepository: repo);

      await provider.fetchProfile();
      expect(provider.profile, isNotNull);
      expect(provider.profile?.name, 'Khin Su Su');

      await provider.updatePreferences(
        language: 'Myanmar (မြန်မာ)',
        notificationsEnabled: false,
      );

      expect(provider.profile?.language, 'Myanmar (မြန်မာ)');
      expect(provider.profile?.notificationsEnabled, false);
    });
  });
}
