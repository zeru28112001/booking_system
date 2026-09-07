import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';
import '../models/time_slot_model.dart';
import '../services/booking_api_service.dart';

/// Concrete implementation of BookingRepository.
/// Calls BookingApiService when a backend exists; otherwise keeps bookings in
/// SharedPreferences so the UI stays populated across restarts.
///
/// Set [useMock] to true while the booking endpoints are unavailable.
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({
    required this._bookingApiService,
    this.useMock = false,
  });

  final BookingApiService _bookingApiService;
  final bool useMock;

  static const _prefKeyBookings = 'stored_bookings';
  static const _firstSlotHour = 9;
  static const _lastSlotHour = 17;

  // ── BookingRepository ─────────────────────────────────────────────────────

  @override
  Future<List<TimeSlot>> getTimeSlots({
    required String providerId,
    required String date,
    String? staffId,
  }) async {
    if (useMock) return _mockTimeSlots(date, staffId);
    return _bookingApiService.getTimeSlots(
      providerId: providerId,
      date: date,
      staffId: staffId,
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
    required String address,
    required String notes,
    required String paymentMethod,
    required int price,
    required int durationMinutes,
    String? staffId,
    String? staffName,
  }) async {
    if (!useMock) {
      return _bookingApiService.createBooking(
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
    }

    await Future.delayed(const Duration(seconds: 1)); // simulate latency
    final now = DateTime.now();
    final booking = BookingModel(
      id: 'BK${now.microsecondsSinceEpoch}',
      providerId: providerId,
      providerName: providerName,
      serviceId: serviceId,
      serviceName: serviceName,
      staffId: staffId,
      staffName: staffName,
      date: date,
      timeSlot: timeSlot,
      address: address,
      notes: notes,
      paymentMethod: paymentMethod,
      status: 'pending',
      price: price,
      durationMinutes: durationMinutes,
      createdAt: now.toIso8601String(),
    );

    final stored = await _storedOrSeeded();
    stored.insert(0, booking); // newest first
    await _writeStored(stored);
    return booking;
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    if (!useMock) return _bookingApiService.getMyBookings();

    await Future.delayed(const Duration(seconds: 1));
    return _storedOrSeeded();
  }

  @override
  Future<Booking> getBookingById(String bookingId) async {
    if (!useMock) return _bookingApiService.getBookingById(bookingId);

    await Future.delayed(const Duration(milliseconds: 600));
    final stored = await _storedOrSeeded();
    for (final booking in stored) {
      if (booking.id == bookingId) return booking;
    }
    throw const NotFoundException('Booking not found.');
  }

  @override
  Future<Booking> cancelBooking(String bookingId) async {
    if (!useMock) return _bookingApiService.cancelBooking(bookingId);

    await Future.delayed(const Duration(seconds: 1));
    final stored = await _storedOrSeeded();
    final index = stored.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) throw const NotFoundException('Booking not found.');
    if (stored[index].status != 'pending') {
      throw const ValidationException('Only pending bookings can be cancelled.');
    }

    final cancelled = stored[index].copyWith(status: 'cancelled');
    stored[index] = cancelled;
    await _writeStored(stored);
    return cancelled;
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  /// Key absent = first run → materialise the two samples so Upcoming and
  /// History are never bare, whichever mock entry point is hit first.
  /// A stored '[]' means the user genuinely emptied the list, so leave it.
  Future<List<BookingModel>> _storedOrSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_prefKeyBookings)) {
      final seeded = _seedBookings();
      await _writeStored(seeded);
      return seeded;
    }
    return _readStored();
  }

  Future<List<BookingModel>> _readStored() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKeyBookings);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return []; // corrupt payload — start clean rather than crash the screen
    }
  }

  Future<void> _writeStored(List<BookingModel> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefKeyBookings,
      jsonEncode(bookings.map((booking) => booking.toJson()).toList()),
    );
  }

  // ── Mock responses ────────────────────────────────────────────────────────

  /// Hourly 09:00–17:00. The day+hour+staff pattern keeps availability stable
  /// between visits while still mixing open and taken slots.
  Future<List<TimeSlot>> _mockTimeSlots(String date, String? staffId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final day = DateTime.parse(date);
    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;
    final staffSeed = staffId != null ? staffId.hashCode : 0;

    return [
      for (var index = 0; index <= _lastSlotHour - _firstSlotHour; index++)
        TimeSlotModel(
          time: '${(_firstSlotHour + index).toString().padLeft(2, '0')}:00',
          isAvailable: (day.day + index + staffSeed) % 3 != 0 &&
              !(isToday &&
                  DateTime(day.year, day.month, day.day, _firstSlotHour + index)
                      .isBefore(now)),
        ),
    ];
  }

  List<BookingModel> _seedBookings() {
    final now = DateTime.now();
    final upcoming = now.add(const Duration(days: 3));
    final past = now.subtract(const Duration(days: 10));

    return [
      BookingModel(
        id: 'BK-seed-1',
        providerId: 'p7',
        providerName: 'Mr. Fix It Plumbing',
        serviceId: 'p7-s1',
        serviceName: 'Tap Repair',
        date: AppFormatters.isoDay(upcoming),
        timeSlot: '10:00',
        address: 'No. 42, Kabar Aye Pagoda Rd, Mayangone',
        notes: 'Kitchen tap drips constantly.',
        paymentMethod: 'cash',
        status: 'accepted',
        price: 10000,
        durationMinutes: 45,
        createdAt: now.toIso8601String(),
      ),
      BookingModel(
        id: 'BK-seed-2',
        providerId: 'p1',
        providerName: 'Glow Beauty Studio',
        serviceId: 'p1-s3',
        serviceName: 'Hair Spa',
        date: AppFormatters.isoDay(past),
        timeSlot: '14:00',
        address: 'No. 42, Kabar Aye Pagoda Rd, Mayangone',
        notes: '',
        paymentMethod: 'myanmyanpay',
        status: 'completed',
        price: 18000,
        durationMinutes: 60,
        createdAt: past.toIso8601String(),
      ),
    ];
  }
}
