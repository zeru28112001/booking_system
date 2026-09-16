import '../../../../core/services/fcm_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../services/profile_api_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required this.profileApiService,
  });

  final ProfileApiService profileApiService;

  @override
  Future<UserProfile> getProfile() async {
    return profileApiService.getProfile();
  }

  @override
  Future<UserProfile> updateProfile({
    String? name,
    String? email,
    List<SavedLocation>? savedLocations,
  }) async {
    return profileApiService.updateProfile(
      name: name,
      email: email,
      savedLocations: savedLocations,
    );
  }

  @override
  Future<UserProfile> updatePreferences({
    String? language,
    bool? notificationsEnabled,
  }) async {
    // 1. Persist the preference to the backend
    final updated = await profileApiService.updatePreferences(
      language: language,
      notificationsEnabled: notificationsEnabled,
    );

    // 2. If the notification toggle changed, register or unregister the FCM token
    if (notificationsEnabled != null) {
      if (notificationsEnabled) {
        // User turned notifications ON → re-register device token
        await FCMService().registerCurrentToken();
      } else {
        // User turned notifications OFF → remove token so backend stops sending
        await FCMService().unregisterTokenWithBackend();
      }
    }

    return updated;
  }
}
