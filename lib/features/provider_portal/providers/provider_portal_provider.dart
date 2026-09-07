import 'package:flutter/foundation.dart';
import 'package:booking_system/features/booking/domain/entities/booking.dart';
import 'package:booking_system/features/provider/domain/entities/service.dart';
import '../domain/entities/provider_profile.dart';
import '../domain/entities/provider_staff.dart';
import '../domain/entities/weekly_schedule.dart';
import '../domain/repositories/provider_portal_repository.dart';

class ProviderPortalProvider extends ChangeNotifier {
  ProviderPortalProvider({required this.providerPortalRepository});

  final ProviderPortalRepository providerPortalRepository;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  ProviderProfile? _profile;
  List<Service> _services = [];
  List<ProviderStaff> _staff = [];
  WeeklySchedule? _schedule;
  List<Booking> _bookings = [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  ProviderProfile? get profile => _profile;
  List<Service> get services => _services;
  List<ProviderStaff> get staff => _staff;
  WeeklySchedule? get schedule => _schedule;
  List<Booking> get bookings => _bookings;

  bool get isAvailable => _profile?.isAvailable ?? true;
  String get verificationStatus => _profile?.verificationStatus ?? 'verified';

  // Revenue & Stats computations (FR-23, FR-24)
  int get totalRevenue {
    return _bookings
        .where((b) => b.status == 'completed' || b.status == 'accepted')
        .fold(0, (sum, b) => sum + b.price);
  }

  int get completedCount {
    return _bookings.where((b) => b.status == 'completed').length;
  }

  List<Booking> get pendingBookings {
    return _bookings.where((b) => b.status == 'pending').toList();
  }

  List<Booking> get activeBookings {
    return _bookings
        .where((b) => b.status == 'accepted' || b.status == 'in_progress')
        .toList();
  }

  Future<void> fetchAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        providerPortalRepository.getProfile(),
        providerPortalRepository.getServices(),
        providerPortalRepository.getStaff(),
        providerPortalRepository.getSchedule(),
        providerPortalRepository.getProviderBookings(),
      ]);
      _profile = results[0] as ProviderProfile;
      _services = results[1] as List<Service>;
      _staff = results[2] as List<ProviderStaff>;
      _schedule = results[3] as WeeklySchedule;
      _bookings = results[4] as List<Booking>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FR-20: Manual Busy/Available Toggle
  Future<void> toggleAvailability(bool val) async {
    if (_profile == null) return;
    try {
      _profile = await providerPortalRepository.toggleAvailability(val);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // FR-21 & FR-22: Booking Accept/Reject & Status Stepper
  Future<bool> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      final updated = await providerPortalRepository.updateBookingStatus(
        bookingId,
        newStatus,
      );
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // FR-17: Sub-services CRUD
  Future<bool> saveService(Service service) async {
    _isSaving = true;
    notifyListeners();
    try {
      if (service.id.isEmpty) {
        final added = await providerPortalRepository.addService(service);
        _services.insert(0, added);
      } else {
        final updated = await providerPortalRepository.updateService(service);
        final idx = _services.indexWhere((s) => s.id == service.id);
        if (idx != -1) _services[idx] = updated;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteService(String serviceId) async {
    try {
      await providerPortalRepository.deleteService(serviceId);
      _services.removeWhere((s) => s.id == serviceId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // FR-18: Staff CRUD
  Future<bool> saveStaff(ProviderStaff member) async {
    _isSaving = true;
    notifyListeners();
    try {
      if (member.id.isEmpty) {
        final added = await providerPortalRepository.addStaff(member);
        _staff.insert(0, added);
      } else {
        final updated = await providerPortalRepository.updateStaff(member);
        final idx = _staff.indexWhere((s) => s.id == member.id);
        if (idx != -1) _staff[idx] = updated;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteStaff(String staffId) async {
    try {
      await providerPortalRepository.deleteStaff(staffId);
      _staff.removeWhere((s) => s.id == staffId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // FR-19: Schedule update
  Future<bool> updateSchedule(WeeklySchedule newSchedule) async {
    _isSaving = true;
    notifyListeners();
    try {
      _schedule = await providerPortalRepository.updateSchedule(newSchedule);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // FR-15: Profile update
  Future<bool> updateProfile(ProviderProfile newProfile) async {
    _isSaving = true;
    notifyListeners();
    try {
      _profile = await providerPortalRepository.updateProfile(newProfile);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
