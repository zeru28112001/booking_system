import 'package:flutter/foundation.dart';
import 'package:booking_system/core/network/socket_service.dart';
import 'package:booking_system/features/booking/data/models/booking_model.dart';
import 'package:booking_system/features/booking/domain/entities/booking.dart';
import 'package:booking_system/features/provider/domain/entities/service.dart';
import '../domain/entities/provider_profile.dart';
import '../domain/entities/provider_staff.dart';
import '../domain/entities/weekly_schedule.dart';
import '../domain/repositories/provider_portal_repository.dart';

import '../domain/entities/provider_payment.dart';
import '../domain/entities/service_group.dart';

import '../domain/entities/payment_method_config.dart';

class ProviderPortalProvider extends ChangeNotifier {
  ProviderPortalProvider({required this.providerPortalRepository});

  final ProviderPortalRepository providerPortalRepository;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  ProviderProfile? _profile;
  List<Service> _services = [];
  List<ServiceGroup> _serviceGroups = [];
  List<ProviderStaff> _staff = [];
  WeeklySchedule? _schedule;
  List<Booking> _bookings = [];
  List<ProviderPayment> _payments = [];
  ProviderPaymentSummary? _paymentSummary;
  List<PaymentMethodConfig> _paymentMethods = [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  ProviderProfile? get profile => _profile;
  List<Service> get services => _services;
  List<ServiceGroup> get serviceGroups => _serviceGroups;
  List<ProviderStaff> get staff => _staff;
  WeeklySchedule? get schedule => _schedule;
  List<Booking> get bookings => _bookings;
  List<ProviderPayment> get payments => _payments;
  ProviderPaymentSummary? get paymentSummary => _paymentSummary;
  List<PaymentMethodConfig> get paymentMethods => _paymentMethods;

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

  bool _isSocketBound = false;

  Future<void> fetchAllData() async {
    if (_isLoading) return;
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
        providerPortalRepository.getServiceGroups(),
      ]);
      _profile = results[0] as ProviderProfile;
      _services = results[1] as List<Service>;
      _staff = results[2] as List<ProviderStaff>;
      _schedule = results[3] as WeeklySchedule;
      _bookings = results[4] as List<Booking>;
      _serviceGroups = results[5] as List<ServiceGroup>;

      // Safely fetch payments without breaking main portal load
      try {
        final payRes = await providerPortalRepository.getPayments();
        _payments = payRes.payments;
        _paymentSummary = payRes.summary;
      } catch (payErr) {
        debugPrint('⚠️ [ProviderPortalProvider] Error fetching payments: $payErr');
      }

      // Safely fetch payment methods
      try {
        _paymentMethods = await providerPortalRepository.getPaymentMethods();
      } catch (pmErr) {
        debugPrint('⚠️ [ProviderPortalProvider] Error fetching payment methods: $pmErr');
      }

      // Connect to Socket.IO room once for real-time incoming booking alerts
      if (_profile != null && _profile!.id.isNotEmpty && !_isSocketBound) {
        _isSocketBound = true;
        debugPrint('📡 [ProviderPortalProvider] Joining room provider_${_profile!.id}');
        SocketService().joinRoom('provider_${_profile!.id}');
        SocketService().onBookingCreated((data) {
          try {
            debugPrint('⚡️ [ProviderPortalProvider] Received booking_created: $data');
            final map = Map<String, dynamic>.from(data as Map);
            final model = BookingModel.fromJson(map);
            _bookings.removeWhere((b) => b.id == model.id);
            _bookings.insert(0, model);
            notifyListeners();
          } catch (e) {
            debugPrint('⚠️ [ProviderPortalProvider] Error parsing booking_created: $e');
          }
        });
        SocketService().onBookingUpdated((data) {
          try {
            debugPrint('⚡️ [ProviderPortalProvider] Received booking_updated: $data');
            final map = Map<String, dynamic>.from(data as Map);
            final model = BookingModel.fromJson(map);
            final index = _bookings.indexWhere((b) => b.id == model.id);
            if (index != -1) {
              _bookings[index] = model;
            } else {
              _bookings.insert(0, model);
            }
            notifyListeners();
          } catch (e) {
            debugPrint('⚠️ [ProviderPortalProvider] Error parsing booking_updated: $e');
          }
        });
      }
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

  // Service Group CRUD
  Future<bool> saveServiceGroup(ServiceGroup group) async {
    _isSaving = true;
    notifyListeners();
    try {
      if (group.id.isEmpty) {
        final added = await providerPortalRepository.addServiceGroup(group);
        _serviceGroups.insert(0, added);
      } else {
        final updated = await providerPortalRepository.updateServiceGroup(group);
        final idx = _serviceGroups.indexWhere((g) => g.id == group.id);
        if (idx != -1) _serviceGroups[idx] = updated;
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

  Future<bool> deleteServiceGroup(String groupId) async {
    try {
      await providerPortalRepository.deleteServiceGroup(groupId);
      _serviceGroups.removeWhere((g) => g.id == groupId);
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

  // Payments CRUD methods
  Future<void> fetchPayments({String? status}) async {
    try {
      final res = await providerPortalRepository.getPayments(status: status);
      _payments = res.payments;
      _paymentSummary = res.summary;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    _isSaving = true;
    notifyListeners();
    try {
      final updated = await providerPortalRepository.updatePaymentStatus(paymentId, status);
      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _payments[index] = updated;
      }
      await fetchPayments();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> createPayment({required double amount, String? paymentMethod, String? status}) async {
    _isSaving = true;
    notifyListeners();
    try {
      final created = await providerPortalRepository.createPayment(
        amount: amount,
        paymentMethod: paymentMethod,
        status: status,
      );
      _payments.insert(0, created);
      await fetchPayments();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Payment Method Config CRUD
  Future<void> fetchPaymentMethods() async {
    try {
      _paymentMethods = await providerPortalRepository.getPaymentMethods();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> savePaymentMethod(PaymentMethodConfig method) async {
    _isSaving = true;
    notifyListeners();
    try {
      if (method.id.isEmpty) {
        final added = await providerPortalRepository.addPaymentMethod(method);
        _paymentMethods.insert(0, added);
      } else {
        final updated = await providerPortalRepository.updatePaymentMethod(method);
        final index = _paymentMethods.indexWhere((p) => p.id == method.id);
        if (index != -1) {
          _paymentMethods[index] = updated;
        } else {
          _paymentMethods.add(updated);
        }
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

  Future<bool> deletePaymentMethod(String id) async {
    try {
      await providerPortalRepository.deletePaymentMethod(id);
      _paymentMethods.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

