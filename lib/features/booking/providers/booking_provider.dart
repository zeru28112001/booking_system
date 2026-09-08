import '../../provider_portal/domain/entities/payment_method_config.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/socket_service.dart';
import '../data/models/booking_model.dart';
import '../domain/entities/booking.dart';
import '../domain/entities/time_slot.dart';
import '../domain/repositories/booking_repository.dart';

/// All booking state: the user's list, one booking detail, and slot availability.
/// Screens never import data/ or call HTTP directly.
class BookingProvider extends ChangeNotifier {
  BookingProvider({required this._bookingRepository}) {
    _initSocketListeners();
  }

  final BookingRepository _bookingRepository;

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  List<Booking> _bookings = [];
  Booking? _booking;
  List<TimeSlot> _timeSlots = [];
  List<PaymentMethodConfig> _providerPaymentMethods = [];
  bool _isLoadingPaymentMethods = false;

  /// True while fetching list, detail or slots.
  bool get isLoading => _isLoading;

  /// True while creating or cancelling — drives button spinners.
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  List<Booking> get bookings => _bookings;
  Booking? get booking => _booking;
  List<TimeSlot> get timeSlots => _timeSlots;
  List<PaymentMethodConfig> get providerPaymentMethods => _providerPaymentMethods;
  bool get isLoadingPaymentMethods => _isLoadingPaymentMethods;

  Future<void> fetchProviderPaymentMethods(String providerId) async {
    _isLoadingPaymentMethods = true;
    notifyListeners();
    try {
      _providerPaymentMethods =
          await _bookingRepository.getProviderPaymentMethods(providerId);
    } catch (e) {
      debugPrint('⚠️ Error fetching payment methods for provider $providerId: $e');
      _providerPaymentMethods = [];
    } finally {
      _isLoadingPaymentMethods = false;
      notifyListeners();
    }
  }

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

  String? _lastSlotsProviderId;
  String? _lastSlotsDate;
  String? _lastSlotsStaffId;
  int? _lastSlotsDurationMinutes;

  void _initSocketListeners() {
    void handleEvent(dynamic data) {
      try {
        debugPrint('⚡️ [BookingProvider] Socket event received: $data');
        final map = Map<String, dynamic>.from(data as Map);
        final model = BookingModel.fromJson(map);

        bool hasChanged = false;
        if (_booking?.id == model.id) {
          _booking = model;
          hasChanged = true;
        }

        final index = _bookings.indexWhere((b) => b.id == model.id);
        if (index != -1) {
          _bookings[index] = model;
          hasChanged = true;
        } else if (_booking?.id == model.id) {
          _bookings.insert(0, model);
          hasChanged = true;
        }

        refreshActiveTimeSlots();

        if (hasChanged) {
          notifyListeners();
        }
      } catch (e) {
        debugPrint('⚠️ [BookingProvider] Error processing socket event: $e');
      }
    }

    SocketService().onBookingUpdated(handleEvent);
    SocketService().onBookingCreated(handleEvent);
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  Future<void> fetchMyBookings() async {
    _setLoading(true);
    try {
      _bookings = await _bookingRepository.getMyBookings();
      _error = null;
      if (_bookings.isNotEmpty) {
        final first = _bookings.first;
        if (first is BookingModel && (first.customerId?.isNotEmpty ?? false)) {
          SocketService().joinRoom('customer_${first.customerId}');
        }
      }
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
      SocketService().joinRoom('booking_$bookingId');
      _booking = await _bookingRepository.getBookingById(bookingId);
      _error = null;
      if (_booking is BookingModel) {
        final custId = (_booking as BookingModel).customerId;
        if (custId != null && custId.isNotEmpty) {
          SocketService().joinRoom('customer_$custId');
        }
      }
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
    int? durationMinutes,
  }) async {
    _lastSlotsProviderId = providerId;
    _lastSlotsDate = date;
    _lastSlotsStaffId = staffId;
    _lastSlotsDurationMinutes = durationMinutes;

    _setLoading(true);
    try {
      _timeSlots = await _bookingRepository.getTimeSlots(
        providerId: providerId,
        date: date,
        staffId: staffId,
        durationMinutes: durationMinutes,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _timeSlots = [];
    } finally {
      _setLoading(false);
    }
  }

  void refreshActiveTimeSlots() {
    if (_lastSlotsProviderId != null && _lastSlotsDate != null) {
      _bookingRepository
          .getTimeSlots(
        providerId: _lastSlotsProviderId!,
        date: _lastSlotsDate!,
        staffId: _lastSlotsStaffId,
        durationMinutes: _lastSlotsDurationMinutes,
      )
          .then((slots) {
        _timeSlots = slots;
        notifyListeners();
      }).catchError((_) {});
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
      if (booking is BookingModel) {
        SocketService().joinRoom('booking_${booking.id}');
        if (booking.customerId?.isNotEmpty ?? false) {
          SocketService().joinRoom('customer_${booking.customerId}');
        }
      }
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
