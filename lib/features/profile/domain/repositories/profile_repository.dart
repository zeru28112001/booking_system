import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();

  Future<UserProfile> updateProfile({
    required String name,
    required String email,
    required String address,
  });

  Future<UserProfile> updatePreferences({
    String? language,
    bool? notificationsEnabled,
  });
}
