import '../../../../core/network/api_client.dart';
import '../models/booking_model.dart';
import '../models/time_slot_model.dart';

/// Handles all booking-flow HTTP calls.
/// Returns typed models — no entities, no notifyListeners.
class BookingApiService {
  const BookingApiService({required this._apiClient});

  final ApiClient _apiClient;

  /// GET /providers/{providerId}/slots?date=yyyy-MM-dd[&staffId=id]
  Future<List<TimeSlotModel>> getTimeSlots({
    required String providerId,
    required String date,
    String? staffId,
  }) async {
    var path =
        '/providers/$providerId/slots?date=${Uri.encodeComponent(date)}';
    if (staffId != null && staffId.isNotEmpty) {
      path += '&staff_id=${Uri.encodeComponent(staffId)}';
    }
    final data = await _apiClient.get(path);
    return _asList(data)
        .map((item) => TimeSlotModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// POST /bookings
  Future<BookingModel> createBooking({
    required String providerId,
    required String providerName,
    required String serviceId,
    required String serviceName,
    required String date,
    required String timeSlot,
    required String address,
    required String notes,
    required String paymentMethod,
    required int price,
    required int durationMinutes,
    String? staffId,
    String? staffName,
  }) async {
    final data = await _apiClient.post(
      '/bookings',
      body: {
        'provider_id': providerId,
        'provider_name': providerName,
        'service_id': serviceId,
        'service_name': serviceName,
        if (staffId case String id) 'staff_id': id,
        if (staffName case String name) 'staff_name': name,
        'date': date,
        'time_slot': timeSlot,
        'address': address,
        'notes': notes,
        'payment_method': paymentMethod,
        'price': price,
        'duration_minutes': durationMinutes,
      },
    );
    return BookingModel.fromJson(_asMap(data));
  }

  /// GET /bookings
  Future<List<BookingModel>> getMyBookings() async {
    final data = await _apiClient.get('/bookings');
    return _asList(data)
        .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// GET /bookings/{bookingId}
  Future<BookingModel> getBookingById(String bookingId) async {
    final data = await _apiClient.get('/bookings/$bookingId');
    return BookingModel.fromJson(_asMap(data));
  }

  /// POST /bookings/{bookingId}/cancel
  Future<BookingModel> cancelBooking(String bookingId) async {
    final data = await _apiClient.post('/bookings/$bookingId/cancel');
    return BookingModel.fromJson(_asMap(data));
  }

  // ── Response shaping ──────────────────────────────────────────────────────

  /// ApiClient normalises an empty body to {}, so unwrap `{ data: ... }` and
  /// tolerate a bare JSON payload.
  List<dynamic> _asList(dynamic data) => data is Map<String, dynamic>
      ? (data['data'] as List<dynamic>? ?? const [])
      : (data as List<dynamic>? ?? const []);

  Map<String, dynamic> _asMap(dynamic data) => data is Map<String, dynamic>
      ? (data['data'] as Map<String, dynamic>? ?? data)
      : <String, dynamic>{};
}
