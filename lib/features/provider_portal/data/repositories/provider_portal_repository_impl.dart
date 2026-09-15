import '../../domain/entities/provider_profile.dart';
import '../../domain/entities/provider_staff.dart';
import '../../domain/entities/weekly_schedule.dart';
import '../../domain/entities/service_group.dart';
import '../../domain/entities/provider_payment.dart';
import '../../domain/entities/payment_method_config.dart';
import '../../domain/repositories/provider_portal_repository.dart';
import '../models/provider_profile_model.dart';
import '../services/provider_portal_api_service.dart';
import '../../../provider/domain/entities/service.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../booking/data/models/booking_model.dart';

class ProviderPortalRepositoryImpl implements ProviderPortalRepository {
  ProviderPortalRepositoryImpl({
    required this.providerPortalApiService,
  });

  final ProviderPortalApiService providerPortalApiService;

  @override
  Future<ProviderProfile> getProfile() async {
    return providerPortalApiService.getProfile();
  }

  @override
  Future<ProviderProfile> updateProfile(ProviderProfile profile) async {
    final model = ProviderProfileModel(
      id: profile.id,
      shopName: profile.shopName,
      categoryName: profile.categoryName,
      description: profile.description,
      address: profile.address,
      phone: profile.phone,
      isAvailable: profile.isAvailable,
      isShop: profile.isShop,
      isHomeService: profile.isHomeService,
      verificationStatus: profile.verificationStatus,
      rating: profile.rating,
      reviewCount: profile.reviewCount,
      imageUrl: profile.imageUrl,
      rejectionReason: profile.rejectionReason,
      latitude: profile.latitude,
      longitude: profile.longitude,
    );
    return providerPortalApiService.updateProfile(model);
  }

  @override
  Future<void> submitProfileChangeRequest(ProviderProfile profile) async {
    final model = ProviderProfileModel(
      id: profile.id,
      shopName: profile.shopName,
      categoryName: profile.categoryName,
      description: profile.description,
      address: profile.address,
      phone: profile.phone,
      isAvailable: profile.isAvailable,
      isShop: profile.isShop,
      isHomeService: profile.isHomeService,
      verificationStatus: profile.verificationStatus,
      rating: profile.rating,
      reviewCount: profile.reviewCount,
      imageUrl: profile.imageUrl,
      rejectionReason: profile.rejectionReason,
      latitude: profile.latitude,
      longitude: profile.longitude,
      hasPendingApproval: profile.hasPendingApproval,
    );
    return providerPortalApiService.submitProfileChangeRequest(model);
  }

  @override
  Future<ProviderProfile> toggleAvailability(bool isAvailable) async {
    return providerPortalApiService.toggleAvailability(isAvailable);
  }

  @override
  Future<List<Service>> getServices() async {
    return providerPortalApiService.getServices();
  }

  @override
  Future<Service> addService(Service service) async {
    return providerPortalApiService.addService(service);
  }

  @override
  Future<Service> updateService(Service service) async {
    return providerPortalApiService.updateService(service);
  }

  @override
  Future<void> deleteService(String serviceId) async {
    return providerPortalApiService.deleteService(serviceId);
  }

  @override
  Future<List<ServiceGroup>> getServiceGroups() async {
    return providerPortalApiService.getServiceGroups();
  }

  @override
  Future<ServiceGroup> addServiceGroup(ServiceGroup group) async {
    return providerPortalApiService.createServiceGroup(group);
  }

  @override
  Future<ServiceGroup> updateServiceGroup(ServiceGroup group) async {
    return providerPortalApiService.updateServiceGroup(group);
  }

  @override
  Future<void> deleteServiceGroup(String groupId) async {
    return providerPortalApiService.deleteServiceGroup(groupId);
  }

  @override
  Future<List<ProviderStaff>> getStaff() async {
    return providerPortalApiService.getStaff();
  }

  @override
  Future<ProviderStaff> addStaff(ProviderStaff staff) async {
    return providerPortalApiService.addStaff(staff);
  }

  @override
  Future<ProviderStaff> updateStaff(ProviderStaff staff) async {
    return providerPortalApiService.updateStaff(staff);
  }

  @override
  Future<void> deleteStaff(String staffId) async {
    return providerPortalApiService.deleteStaff(staffId);
  }

  @override
  Future<WeeklySchedule> getSchedule() async {
    return providerPortalApiService.getSchedule();
  }

  @override
  Future<WeeklySchedule> updateSchedule(WeeklySchedule schedule) async {
    return providerPortalApiService.updateSchedule(schedule);
  }

  @override
  Future<List<Booking>> getProviderBookings() async {
    final rawList = await providerPortalApiService.getProviderBookingsRaw();
    return rawList.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Booking> updateBookingStatus(String bookingId, String newStatus) async {
    final raw = await providerPortalApiService.updateBookingStatusRaw(bookingId, newStatus);
    return BookingModel.fromJson(raw);
  }

  @override
  Future<({List<ProviderPayment> payments, ProviderPaymentSummary summary})> getPayments({String? status}) async {
    final res = await providerPortalApiService.getPaymentsRaw(status: status);
    final rawList = res['payments'] as List<dynamic>? ?? [];
    final payments = rawList.map((item) => ProviderPayment.fromJson(item as Map<String, dynamic>)).toList();
    final summary = ProviderPaymentSummary.fromJson(res['summary'] as Map<String, dynamic>? ?? {});
    return (payments: payments, summary: summary);
  }

  @override
  Future<ProviderPayment> updatePaymentStatus(String paymentId, String status) async {
    final raw = await providerPortalApiService.updatePaymentStatusRaw(paymentId, status);
    return ProviderPayment.fromJson(raw);
  }

  @override
  Future<ProviderPayment> createPayment({required double amount, String? paymentMethod, String? status}) async {
    final raw = await providerPortalApiService.createPaymentRaw(
      amount: amount,
      paymentMethod: paymentMethod,
      status: status,
    );
    return ProviderPayment.fromJson(raw);
  }

  @override
  Future<List<PaymentMethodConfig>> getPaymentMethods() async {
    final list = await providerPortalApiService.getPaymentMethodsRaw();
    return list.map((item) => PaymentMethodConfig.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<PaymentMethodConfig> addPaymentMethod(PaymentMethodConfig method) async {
    final raw = await providerPortalApiService.createPaymentMethodRaw(method.toJson());
    return PaymentMethodConfig.fromJson(raw);
  }

  @override
  Future<PaymentMethodConfig> updatePaymentMethod(PaymentMethodConfig method) async {
    final raw = await providerPortalApiService.updatePaymentMethodRaw(method.id, method.toJson());
    return PaymentMethodConfig.fromJson(raw);
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    await providerPortalApiService.deletePaymentMethodRaw(id);
  }
}

