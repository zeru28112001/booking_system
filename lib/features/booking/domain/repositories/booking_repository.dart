import '../../../provider_portal/domain/entities/payment_method_config.dart';
import '../entities/booking.dart';
import '../entities/time_slot.dart';

/// Booking-flow contract: slots, create, list, detail, cancel.
/// Implemented by BookingRepositoryImpl; consumed only by BookingProvider.
abstract class BookingRepository {
  /// Available payment methods for a provider
  Future<List<PaymentMethodConfig>> getProviderPaymentMethods(String providerId);

  /// Available slots for one provider on one 'yyyy-MM-dd' date, optionally filtered by staffId.
  Future<List<TimeSlot>> getTimeSlots({
    required String providerId,
    required String date,
    String? staffId,
    int? durationMinutes,
  });

  /// Creates a booking in 'pending' status and returns it.
  Future<Booking> createBooking({
    required String providerId,
    required String providerName,
    required String serviceId,
    required String serviceName,
    required String date,
    required String timeSlot,
    String bookingType = 'in_shop',
    required String address,
    double? latitude,
    double? longitude,
    required String notes,
    required String paymentMethod,
    required int price,
    required int durationMinutes,
    String? staffId,
    String? staffName,
  });

  Future<List<Booking>> getMyBookings();

  /// Throws NotFoundException when the id is unknown.
  Future<Booking> getBookingById(String bookingId);

  /// Throws ValidationException unless the booking is still 'pending'.
  Future<Booking> cancelBooking(String bookingId);
}
