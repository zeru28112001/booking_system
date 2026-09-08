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
    required String name,
    required String email,
    required String address,
  }) async {
    return profileApiService.updateProfile(
      name: name,
      email: email,
      address: address,
    );
  }

  @override
  Future<UserProfile> updatePreferences({
    String? language,
    bool? notificationsEnabled,
  }) async {
    final current = await profileApiService.getProfile();
    return profileApiService.updateProfile(
      name: current.name,
      email: current.email,
      address: current.address,
    );
  }
}
