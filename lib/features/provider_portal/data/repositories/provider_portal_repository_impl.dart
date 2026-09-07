import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/provider_profile.dart';
import '../../domain/entities/provider_staff.dart';
import '../../domain/entities/weekly_schedule.dart';
import '../../domain/repositories/provider_portal_repository.dart';
import '../models/provider_profile_model.dart';
import '../models/provider_staff_model.dart';
import '../models/weekly_schedule_model.dart';
import '../services/provider_portal_api_service.dart';
import '../../../provider/domain/entities/service.dart';
import '../../../provider/data/models/service_model.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../booking/data/models/booking_model.dart';

class ProviderPortalRepositoryImpl implements ProviderPortalRepository {
  ProviderPortalRepositoryImpl({
    required this.providerPortalApiService,
    this.useMock = true,
  });

  final ProviderPortalApiService providerPortalApiService;
  final bool useMock;

  static const _keyProfile = 'provider_portal_profile';
  static const _keyServices = 'provider_portal_services';
  static const _keyStaff = 'provider_portal_staff';
  static const _keySchedule = 'provider_portal_schedule';
  static const _keyBookings = 'provider_portal_bookings';

  @override
  Future<ProviderProfile> getProfile() async {
    if (!useMock) return providerPortalApiService.getProfile();
    await Future.delayed(const Duration(milliseconds: 300));
    return _readProfile();
  }

  @override
  Future<ProviderProfile> updateProfile(ProviderProfile profile) async {
    final model = ProviderProfileModel(
      id: profile.id,
      shopName: profile.shopName,
      categoryName: profile.categoryName,
      description: profile.description,
      address: profile.address,
      phone: profile.phone,
      isAvailable: profile.isAvailable,
      verificationStatus: profile.verificationStatus,
      rating: profile.rating,
      reviewCount: profile.reviewCount,
      imageUrl: profile.imageUrl,
      rejectionReason: profile.rejectionReason,
    );
    if (!useMock) return providerPortalApiService.updateProfile(model);
    await _writeProfile(model);
    return model;
  }

  @override
  Future<ProviderProfile> toggleAvailability(bool isAvailable) async {
    final current = await getProfile();
    final updated = (current as ProviderProfileModel).copyWith(isAvailable: isAvailable);
    await _writeProfile(updated);
    return updated;
  }

  @override
  Future<List<Service>> getServices() async {
    if (!useMock) return providerPortalApiService.getServices();
    await Future.delayed(const Duration(milliseconds: 300));
    return _readServices();
  }

  @override
  Future<Service> addService(Service service) async {
    final services = await _readServices();
    final model = ServiceModel(
      id: service.id.isEmpty ? 'srv_${DateTime.now().millisecondsSinceEpoch}' : service.id,
      name: service.name,
      group: service.group.isEmpty ? 'General' : service.group,
      price: service.price,
      durationMinutes: service.durationMinutes,
    );
    services.insert(0, model);
    await _writeServices(services);
    return model;
  }

  @override
  Future<Service> updateService(Service service) async {
    final services = await _readServices();
    final index = services.indexWhere((s) => s.id == service.id);
    final model = ServiceModel(
      id: service.id,
      name: service.name,
      group: service.group.isEmpty ? 'General' : service.group,
      price: service.price,
      durationMinutes: service.durationMinutes,
    );
    if (index != -1) {
      services[index] = model;
    } else {
      services.add(model);
    }
    await _writeServices(services);
    return model;
  }

  @override
  Future<void> deleteService(String serviceId) async {
    final services = await _readServices();
    services.removeWhere((s) => s.id == serviceId);
    await _writeServices(services);
  }

  @override
  Future<List<ProviderStaff>> getStaff() async {
    if (!useMock) return providerPortalApiService.getStaff();
    await Future.delayed(const Duration(milliseconds: 300));
    return _readStaff();
  }

  @override
  Future<ProviderStaff> addStaff(ProviderStaff staff) async {
    final staffList = await _readStaff();
    final model = ProviderStaffModel(
      id: staff.id.isEmpty ? 'stf_${DateTime.now().millisecondsSinceEpoch}' : staff.id,
      name: staff.name,
      phone: staff.phone,
      specialties: staff.specialties,
      isActive: staff.isActive,
      avatarUrl: staff.avatarUrl,
    );
    staffList.insert(0, model);
    await _writeStaff(staffList);
    return model;
  }

  @override
  Future<ProviderStaff> updateStaff(ProviderStaff staff) async {
    final staffList = await _readStaff();
    final index = staffList.indexWhere((s) => s.id == staff.id);
    final model = ProviderStaffModel(
      id: staff.id,
      name: staff.name,
      phone: staff.phone,
      specialties: staff.specialties,
      isActive: staff.isActive,
      avatarUrl: staff.avatarUrl,
    );
    if (index != -1) {
      staffList[index] = model;
    } else {
      staffList.add(model);
    }
    await _writeStaff(staffList);
    return model;
  }

  @override
  Future<void> deleteStaff(String staffId) async {
    final staffList = await _readStaff();
    staffList.removeWhere((s) => s.id == staffId);
    await _writeStaff(staffList);
  }

  @override
  Future<WeeklySchedule> getSchedule() async {
    if (!useMock) return providerPortalApiService.getSchedule();
    await Future.delayed(const Duration(milliseconds: 300));
    return _readSchedule();
  }

  @override
  Future<WeeklySchedule> updateSchedule(WeeklySchedule schedule) async {
    final model = WeeklyScheduleModel(
      days: schedule.days
          .map((d) => DayScheduleModel(
                dayName: d.dayName,
                isOpen: d.isOpen,
                startTime: d.startTime,
                endTime: d.endTime,
              ))
          .toList(),
    );
    await _writeSchedule(model);
    return model;
  }

  @override
  Future<List<Booking>> getProviderBookings() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _readBookings();
  }

  @override
  Future<Booking> updateBookingStatus(String bookingId, String newStatus) async {
    final bookings = await _readBookings();
    final index = bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw Exception('Booking not found');
    }
    final current = bookings[index];
    final updated = BookingModel(
      id: current.id,
      providerId: current.providerId,
      providerName: current.providerName,
      serviceId: current.serviceId,
      serviceName: current.serviceName,
      date: current.date,
      timeSlot: current.timeSlot,
      address: current.address,
      notes: current.notes,
      status: newStatus,
      paymentMethod: current.paymentMethod,
      price: current.price,
      durationMinutes: current.durationMinutes,
      createdAt: current.createdAt,
    );
    bookings[index] = updated;
    await _writeBookings(bookings);
    return updated;
  }

  // --- Persistence helpers ---

  Future<ProviderProfileModel> _readProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyProfile);
    if (raw == null) {
      const defaultProfile = ProviderProfileModel(
        id: 'prov_001',
        shopName: 'Glow Beauty Studio',
        categoryName: 'Beauty & Salon',
        description: 'Premium hair styling, coloring, manicure, and spa treatments.',
        address: 'No. 42, Kabar Aye Pagoda Rd, Mayangone, Yangon',
        phone: '09 987 654 321',
        isAvailable: true,
        verificationStatus: 'verified',
        rating: 4.9,
        reviewCount: 28,
        imageUrl: 'https://picsum.photos/400/300?random=10',
      );
      await _writeProfile(defaultProfile);
      return defaultProfile;
    }
    return ProviderProfileModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _writeProfile(ProviderProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  Future<List<ServiceModel>> _readServices() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyServices);
    if (raw == null) {
      const initial = [
        ServiceModel(
          id: 'p1-s1',
          name: 'Haircut & Styling',
          group: 'Hair',
          price: 8000,
          durationMinutes: 45,
        ),
        ServiceModel(
          id: 'p1-s2',
          name: 'Hair Coloring',
          group: 'Hair',
          price: 25000,
          durationMinutes: 90,
        ),
        ServiceModel(
          id: 'p1-s3',
          name: 'Manicure & Pedicure',
          group: 'Nails',
          price: 15000,
          durationMinutes: 60,
        ),
      ];
      await _writeServices(initial);
      return initial;
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _writeServices(List<ServiceModel> services) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServices, jsonEncode(services.map((s) => s.toJson()).toList()));
  }

  Future<List<ProviderStaffModel>> _readStaff() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyStaff);
    if (raw == null) {
      const initial = [
        ProviderStaffModel(
          id: 'stf_1',
          name: 'Aye Aye Win',
          phone: '09 111 222 333',
          specialties: ['Haircut', 'Hair Coloring'],
          isActive: true,
          avatarUrl: '',
        ),
        ProviderStaffModel(
          id: 'stf_2',
          name: 'Khin Thandar',
          phone: '09 444 555 666',
          specialties: ['Manicure', 'Nail Art'],
          isActive: true,
          avatarUrl: '',
        ),
      ];
      await _writeStaff(initial);
      return initial;
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => ProviderStaffModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _writeStaff(List<ProviderStaffModel> staff) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStaff, jsonEncode(staff.map((s) => s.toJson()).toList()));
  }

  Future<WeeklyScheduleModel> _readSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySchedule);
    if (raw == null) {
      const initial = WeeklyScheduleModel(days: [
        DayScheduleModel(dayName: 'Monday', isOpen: true, startTime: '09:00', endTime: '18:00'),
        DayScheduleModel(dayName: 'Tuesday', isOpen: true, startTime: '09:00', endTime: '18:00'),
        DayScheduleModel(dayName: 'Wednesday', isOpen: true, startTime: '09:00', endTime: '18:00'),
        DayScheduleModel(dayName: 'Thursday', isOpen: true, startTime: '09:00', endTime: '18:00'),
        DayScheduleModel(dayName: 'Friday', isOpen: true, startTime: '09:00', endTime: '18:00'),
        DayScheduleModel(dayName: 'Saturday', isOpen: true, startTime: '10:00', endTime: '19:00'),
        DayScheduleModel(dayName: 'Sunday', isOpen: false, startTime: '09:00', endTime: '18:00'),
      ]);
      await _writeSchedule(initial);
      return initial;
    }
    return WeeklyScheduleModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _writeSchedule(WeeklyScheduleModel schedule) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySchedule, jsonEncode(schedule.toJson()));
  }

  Future<List<BookingModel>> _readBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyBookings);
    if (raw == null) {
      final initial = [
        BookingModel(
          id: 'BK_PRV_001',
          providerId: 'prov_001',
          providerName: 'Glow Beauty Studio',
          serviceId: 'p1-s1',
          serviceName: 'Haircut & Styling',
          date: '2026-09-08',
          timeSlot: '10:00',
          address: 'No. 12, Pyay Rd, Dagon Tsp',
          notes: 'Prefer Aye Aye Win',
          status: 'pending',
          paymentMethod: 'cash',
          price: 8000,
          durationMinutes: 45,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        ),
        BookingModel(
          id: 'BK_PRV_002',
          providerId: 'prov_001',
          providerName: 'Glow Beauty Studio',
          serviceId: 'p1-s2',
          serviceName: 'Hair Coloring',
          date: '2026-09-08',
          timeSlot: '14:00',
          address: 'No. 88, Insein Rd',
          notes: 'Bring gel sample',
          status: 'accepted',
          paymentMethod: 'myanmyanpay',
          price: 25000,
          durationMinutes: 90,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        ),
        BookingModel(
          id: 'BK_PRV_003',
          providerId: 'prov_001',
          providerName: 'Glow Beauty Studio',
          serviceId: 'p1-s3',
          serviceName: 'Manicure & Pedicure',
          date: '2026-09-07',
          timeSlot: '11:00',
          address: 'Shop Visit',
          notes: '',
          status: 'completed',
          paymentMethod: 'cash',
          price: 15000,
          durationMinutes: 60,
          createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        ),
      ];
      await _writeBookings(initial);
      return initial;
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _writeBookings(List<BookingModel> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBookings, jsonEncode(bookings.map((b) => b.toJson()).toList()));
  }
}
