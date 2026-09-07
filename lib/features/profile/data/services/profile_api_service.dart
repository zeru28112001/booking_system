import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';

class ProfileApiService {
  const ProfileApiService({required this.apiClient});

  final ApiClient apiClient;

  Future<ProfileModel> getProfile() async {
    final data = await apiClient.get('/profile');
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return ProfileModel.fromJson(map);
  }

  Future<ProfileModel> updateProfile({
    required String name,
    required String email,
    required String address,
  }) async {
    final data = await apiClient.put(
      '/profile',
      body: {
        'name': name,
        'email': email,
        'address': address,
      },
    );
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return ProfileModel.fromJson(map);
  }
}
