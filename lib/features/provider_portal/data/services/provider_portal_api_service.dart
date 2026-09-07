import '../../../../core/network/api_client.dart';
import '../models/provider_profile_model.dart';
import '../models/provider_staff_model.dart';
import '../models/weekly_schedule_model.dart';
import '../../../provider/data/models/service_model.dart';

class ProviderPortalApiService {
  const ProviderPortalApiService({required this.apiClient});

  final ApiClient apiClient;

  Future<ProviderProfileModel> getProfile() async {
    final data = await apiClient.get('/provider-portal/profile');
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return ProviderProfileModel.fromJson(map);
  }

  Future<ProviderProfileModel> updateProfile(ProviderProfileModel profile) async {
    final data = await apiClient.put(
      '/provider-portal/profile',
      body: profile.toJson(),
    );
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return ProviderProfileModel.fromJson(map);
  }

  Future<List<ServiceModel>> getServices() async {
    final data = await apiClient.get('/provider-portal/services');
    final list = data is Map<String, dynamic>
        ? (data['data'] as List<dynamic>? ?? const [])
        : (data as List<dynamic>? ?? const []);
    return list
        .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProviderStaffModel>> getStaff() async {
    final data = await apiClient.get('/provider-portal/staff');
    final list = data is Map<String, dynamic>
        ? (data['data'] as List<dynamic>? ?? const [])
        : (data as List<dynamic>? ?? const []);
    return list
        .map((item) => ProviderStaffModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<WeeklyScheduleModel> getSchedule() async {
    final data = await apiClient.get('/provider-portal/schedule');
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return WeeklyScheduleModel.fromJson(map);
  }
}
