import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();

  Future<UserProfile> updateProfile({
    String? name,
    String? email,
    String? address,
    List<SavedLocation>? savedLocations,
  });

  Future<UserProfile> updatePreferences({
    String? language,
    bool? notificationsEnabled,
  });
}
