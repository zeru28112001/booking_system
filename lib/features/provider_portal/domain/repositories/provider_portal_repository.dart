import 'package:booking_system/features/booking/domain/entities/booking.dart';
import 'package:booking_system/features/provider/domain/entities/service.dart';
import '../entities/provider_profile.dart';
import '../entities/provider_staff.dart';
import '../entities/weekly_schedule.dart';
import '../entities/service_group.dart';
import '../entities/provider_payment.dart';
import '../entities/payment_method_config.dart';

abstract class ProviderPortalRepository {
  Future<ProviderProfile> getProfile();
  Future<ProviderProfile> updateProfile(ProviderProfile profile);
  Future<ProviderProfile> toggleAvailability(bool isAvailable);

  Future<List<Service>> getServices();
  Future<Service> addService(Service service);
  Future<Service> updateService(Service service);
  Future<void> deleteService(String serviceId);

  Future<List<ServiceGroup>> getServiceGroups();
  Future<ServiceGroup> addServiceGroup(ServiceGroup group);
  Future<ServiceGroup> updateServiceGroup(ServiceGroup group);
  Future<void> deleteServiceGroup(String groupId);

  Future<List<ProviderStaff>> getStaff();
  Future<ProviderStaff> addStaff(ProviderStaff staff);
  Future<ProviderStaff> updateStaff(ProviderStaff staff);
  Future<void> deleteStaff(String staffId);

  Future<WeeklySchedule> getSchedule();
  Future<WeeklySchedule> updateSchedule(WeeklySchedule schedule);

  Future<List<Booking>> getProviderBookings();
  Future<Booking> updateBookingStatus(String bookingId, String newStatus);

  Future<({List<ProviderPayment> payments, ProviderPaymentSummary summary})> getPayments({String? status});
  Future<ProviderPayment> updatePaymentStatus(String paymentId, String status);
  Future<ProviderPayment> createPayment({required double amount, String? paymentMethod, String? status});

  Future<List<PaymentMethodConfig>> getPaymentMethods();
  Future<PaymentMethodConfig> addPaymentMethod(PaymentMethodConfig method);
  Future<PaymentMethodConfig> updatePaymentMethod(PaymentMethodConfig method);
  Future<void> deletePaymentMethod(String id);
}

