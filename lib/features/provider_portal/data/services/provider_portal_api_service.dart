import '../../../../core/network/api_client.dart';
import '../models/provider_profile_model.dart';
import '../models/provider_staff_model.dart';
import '../models/weekly_schedule_model.dart';
import '../models/service_group_model.dart';
import '../../domain/entities/service_group.dart';
import '../../../provider/domain/entities/service.dart';
import '../../../provider/data/models/service_model.dart';
import '../../../provider_portal/domain/entities/provider_staff.dart';
import '../../../provider_portal/domain/entities/weekly_schedule.dart';

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

  Future<ProviderProfileModel> toggleAvailability(bool isAvailable) async {
    final data = await apiClient.patch('/provider-portal/availability', body: {
      'isAvailable': isAvailable,
    });
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

  Future<ServiceModel> addService(Service service) async {
    final data = await apiClient.post('/provider-portal/services', body: {
      'name': service.name,
      'group': service.group,
      'price': service.price,
      'durationMinutes': service.durationMinutes,
    });
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return ServiceModel.fromJson(map);
  }

  Future<ServiceModel> updateService(Service service) async {
    final data = await apiClient.put('/provider-portal/services/${service.id}', body: {
      'name': service.name,
      'group': service.group,
      'price': service.price,
      'durationMinutes': service.durationMinutes,
    });
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return ServiceModel.fromJson(map);
  }

  Future<void> deleteService(String serviceId) async {
    await apiClient.delete('/provider-portal/services/$serviceId');
  }

  Future<List<ServiceGroupModel>> getServiceGroups() async {
    final data = await apiClient.get('/provider-portal/service-groups');
    final list = data is Map<String, dynamic>
        ? (data['data'] as List<dynamic>? ?? const [])
        : (data as List<dynamic>? ?? const []);
    return list
        .map((item) => ServiceGroupModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceGroupModel> createServiceGroup(ServiceGroup group) async {
    final data = await apiClient.post('/provider-portal/service-groups', body: {
      'name': group.name,
      'description': group.description,
      'iconName': group.iconName,
      'sortOrder': group.sortOrder,
    });
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return ServiceGroupModel.fromJson(map);
  }

  Future<ServiceGroupModel> updateServiceGroup(ServiceGroup group) async {
    final data = await apiClient.put('/provider-portal/service-groups/${group.id}', body: {
      'name': group.name,
      'description': group.description,
      'iconName': group.iconName,
      'sortOrder': group.sortOrder,
      'isActive': group.isActive,
    });
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return ServiceGroupModel.fromJson(map);
  }

  Future<void> deleteServiceGroup(String groupId) async {
    await apiClient.delete('/provider-portal/service-groups/$groupId');
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

  Future<ProviderStaffModel> addStaff(ProviderStaff staff) async {
    final data = await apiClient.post('/provider-portal/staff', body: {
      'name': staff.name,
      'phone': staff.phone,
      'specialties': staff.specialties,
      'isActive': staff.isActive,
      'avatarUrl': staff.avatarUrl,
    });
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return ProviderStaffModel.fromJson(map);
  }

  Future<ProviderStaffModel> updateStaff(ProviderStaff staff) async {
    final data = await apiClient.put('/provider-portal/staff/${staff.id}', body: {
      'name': staff.name,
      'phone': staff.phone,
      'specialties': staff.specialties,
      'isActive': staff.isActive,
      'avatarUrl': staff.avatarUrl,
    });
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return ProviderStaffModel.fromJson(map);
  }

  Future<void> deleteStaff(String staffId) async {
    await apiClient.delete('/provider-portal/staff/$staffId');
  }

  Future<WeeklyScheduleModel> getSchedule() async {
    final data = await apiClient.get('/provider-portal/schedule');
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return WeeklyScheduleModel.fromJson(map);
  }

  Future<WeeklyScheduleModel> updateSchedule(WeeklySchedule schedule) async {
    final data = await apiClient.put('/provider-portal/schedule', body: {
      'days': schedule.days
          .map((d) => {
                'dayName': d.dayName,
                'isOpen': d.isOpen,
                'startTime': d.startTime,
                'endTime': d.endTime,
              })
          .toList(),
    });
    final map = data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
    return WeeklyScheduleModel.fromJson(map);
  }

  Future<List<dynamic>> getProviderBookingsRaw() async {
    final data = await apiClient.get('/provider-portal/bookings');
    return data is Map<String, dynamic>
        ? (data['data'] as List<dynamic>? ?? const [])
        : (data as List<dynamic>? ?? const []);
  }

  Future<Map<String, dynamic>> updateBookingStatusRaw(String bookingId, String status) async {
    final data = await apiClient.patch('/provider-portal/bookings/$bookingId/status', body: {
      'status': status,
    });
    return data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getPaymentsRaw({String? status}) async {
    final query = status != null && status.isNotEmpty ? '?status=$status' : '';
    final data = await apiClient.get('/provider-portal/payments$query');
    return data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updatePaymentStatusRaw(String paymentId, String status) async {
    final data = await apiClient.patch('/provider-portal/payments/$paymentId/status', body: {
      'status': status,
    });
    return data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> createPaymentRaw({
    required double amount,
    String? paymentMethod,
    String? status,
  }) async {
    final data = await apiClient.post('/provider-portal/payments', body: {
      'amount': amount,
      'paymentMethod': paymentMethod ?? 'cash',
      'status': status ?? 'completed',
    });
    return data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
  }

  Future<List<dynamic>> getPaymentMethodsRaw() async {
    final data = await apiClient.get('/provider-portal/payment-methods');
    return data is Map<String, dynamic>
        ? (data['data'] as List<dynamic>? ?? const [])
        : (data as List<dynamic>? ?? const []);
  }

  Future<Map<String, dynamic>> createPaymentMethodRaw(Map<String, dynamic> body) async {
    final data = await apiClient.post('/provider-portal/payment-methods', body: body);
    return data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updatePaymentMethodRaw(String id, Map<String, dynamic> body) async {
    final data = await apiClient.put('/provider-portal/payment-methods/$id', body: body);
    return data is Map<String, dynamic>
        ? (data['data'] as Map<String, dynamic>? ?? data)
        : <String, dynamic>{};
  }

  Future<void> deletePaymentMethodRaw(String id) async {
    await apiClient.delete('/provider-portal/payment-methods/$id');
  }
}
