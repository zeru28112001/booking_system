import '../../../provider_portal/domain/entities/payment_method_config.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import '../services/booking_api_service.dart';

/// Concrete implementation of BookingRepository.
/// Calls BookingApiService for all booking operations.
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({
    required this.bookingApiService,
  });

  final BookingApiService bookingApiService;

  // ── BookingRepository ─────────────────────────────────────────────────────

  @override
  Future<List<PaymentMethodConfig>> getProviderPaymentMethods(
      String providerId) async {
    return bookingApiService.getProviderPaymentMethods(providerId);
  }

  @override
  Future<List<TimeSlot>> getTimeSlots({
    required String providerId,
    required String date,
    String? staffId,
    int? durationMinutes,
  }) async {
    return bookingApiService.getTimeSlots(
      providerId: providerId,
      date: date,
      staffId: staffId,
      durationMinutes: durationMinutes,
    );
  }

  @override
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
  }) async {
    return bookingApiService.createBooking(
      providerId: providerId,
      providerName: providerName,
      serviceId: serviceId,
      serviceName: serviceName,
      date: date,
      timeSlot: timeSlot,
      bookingType: bookingType,
      address: address,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
      paymentMethod: paymentMethod,
      price: price,
      durationMinutes: durationMinutes,
      staffId: staffId,
      staffName: staffName,
    );
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    return bookingApiService.getMyBookings();
  }

  @override
  Future<Booking> getBookingById(String bookingId) async {
    return bookingApiService.getBookingById(bookingId);
  }

  @override
  Future<Booking> cancelBooking(String bookingId) async {
    return bookingApiService.cancelBooking(bookingId);
  }
}

