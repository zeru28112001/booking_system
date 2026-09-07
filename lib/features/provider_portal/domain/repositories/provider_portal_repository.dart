import 'package:booking_system/features/booking/domain/entities/booking.dart';
import 'package:booking_system/features/provider/domain/entities/service.dart';
import '../entities/provider_profile.dart';
import '../entities/provider_staff.dart';
import '../entities/weekly_schedule.dart';

abstract class ProviderPortalRepository {
  Future<ProviderProfile> getProfile();
  Future<ProviderProfile> updateProfile(ProviderProfile profile);
  Future<ProviderProfile> toggleAvailability(bool isAvailable);

  Future<List<Service>> getServices();
  Future<Service> addService(Service service);
  Future<Service> updateService(Service service);
  Future<void> deleteService(String serviceId);

  Future<List<ProviderStaff>> getStaff();
  Future<ProviderStaff> addStaff(ProviderStaff staff);
  Future<ProviderStaff> updateStaff(ProviderStaff staff);
  Future<void> deleteStaff(String staffId);

  Future<WeeklySchedule> getSchedule();
  Future<WeeklySchedule> updateSchedule(WeeklySchedule schedule);

  Future<List<Booking>> getProviderBookings();
  Future<Booking> updateBookingStatus(String bookingId, String newStatus);
}
