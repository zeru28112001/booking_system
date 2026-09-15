import '../../../../core/network/api_client.dart';
import '../../domain/entities/user_profile.dart';
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
    String? name,
    String? email,
    String? address,
    List<SavedLocation>? savedLocations,
  }) async {
    final data = await apiClient.put(
      '/profile',
      body: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
        if (savedLocations != null)
          'savedLocations': savedLocations
              .map((e) => {
                    'label': e.label,
                    'address': e.address,
                    'location': {
                      'type': 'Point',
                      'coordinates': [e.longitude, e.latitude],
                    }
                  })
              .toList(),
      },
    );
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return ProfileModel.fromJson(map);
  }
}
