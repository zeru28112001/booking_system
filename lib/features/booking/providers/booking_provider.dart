import 'package:flutter/foundation.dart';
import '../domain/entities/booking.dart';
import '../domain/entities/time_slot.dart';
import '../domain/repositories/booking_repository.dart';

/// All booking state: the user's list, one booking detail, and slot availability.
/// Screens never import data/ or call HTTP directly.
class BookingProvider extends ChangeNotifier {
  BookingProvider({required this._bookingRepository});

  final BookingRepository _bookingRepository;

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  List<Booking> _bookings = [];
  Booking? _booking;
  List<TimeSlot> _timeSlots = [];

  /// True while fetching list, detail or slots.
  bool get isLoading => _isLoading;

  /// True while creating or cancelling — drives button spinners.
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  List<Booking> get bookings => _bookings;
  Booking? get booking => _booking;
  List<TimeSlot> get timeSlots => _timeSlots;

  List<Booking> get pendingBookings =>
      _bookings.where((booking) => booking.status == 'pending').toList();

  List<Booking> get upcomingBookings => _bookings
      .where((booking) =>
          booking.status == 'accepted' || booking.status == 'in_progress')
      .toList();

  List<Booking> get historyBookings => _bookings
      .where((booking) =>
          booking.status == 'completed' || booking.status == 'cancelled')
      .toList();

  // ── Queries ───────────────────────────────────────────────────────────────

  Future<void> fetchMyBookings() async {
    _setLoading(true);
    try {
      _bookings = await _bookingRepository.getMyBookings();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _bookings = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchBookingById(String bookingId) async {
    _setLoading(true);
    try {
      _booking = await _bookingRepository.getBookingById(bookingId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _booking = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTimeSlots({
    required String providerId,
    required String date,
    String? staffId,
  }) async {
    _setLoading(true);
    try {
      _timeSlots = await _bookingRepository.getTimeSlots(
        providerId: providerId,
        date: date,
        staffId: staffId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _timeSlots = [];
    } finally {
      _setLoading(false);
    }
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Returns the created booking, or null when the request failed (see [error]).
  Future<Booking?> createBooking({
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
    _setSubmitting(true);
    try {
      final booking = await _bookingRepository.createBooking(
        providerId: providerId,
        providerName: providerName,
        serviceId: serviceId,
        serviceName: serviceName,
        date: date,
        timeSlot: timeSlot,
        address: address,
        notes: notes,
        paymentMethod: paymentMethod,
        price: price,
        durationMinutes: durationMinutes,
        staffId: staffId,
        staffName: staffName,
      );
      _bookings.insert(0, booking);
      _booking = booking;
      _error = null;
      return booking;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    _setSubmitting(true);
    try {
      final cancelled = await _bookingRepository.cancelBooking(bookingId);
      final index = _bookings.indexWhere((booking) => booking.id == bookingId);
      if (index != -1) _bookings[index] = cancelled;
      if (_booking?.id == bookingId) _booking = cancelled;
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }
}
