import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../booking/data/models/booking_model.dart';
import '../../home/data/models/category_model.dart';
import '../../provider_portal/data/models/provider_profile_model.dart';
import '../data/models/promo_banner_model.dart';
import '../data/models/provider_profile_request_model.dart';
import '../data/models/system_settings_model.dart';

class AdminPortalProvider extends ChangeNotifier {
  AdminPortalProvider({this.apiClient});

  final ApiClient? apiClient;

  bool _isLoading = false;
  String? _error;

  List<ProviderProfileModel> _providers = [];
  List<ProviderProfileRequestModel> _pendingProfileRequests = [];
  List<BookingModel> _allBookings = [];
  List<CategoryModel> _categories = [];
  List<PromoBannerModel> _banners = [];
  SystemSettingsModel _systemSettings = const SystemSettingsModel(
    supportPhone: '09 123 456 780',
    supportEmail: 'support@bookingsystem.mm',
    isMaintenanceMode: false,
  );

  int _totalCustomersCount = 0;
  int _totalBookingsCount = 0;
  double _totalRevenue = 0;
  int _pendingProfileRequestsCount = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProviderProfileModel> get providers => _providers;
  List<ProviderProfileRequestModel> get pendingProfileRequests => _pendingProfileRequests;
  List<BookingModel> get allBookings => _allBookings;
  List<CategoryModel> get categories => _categories;
  List<PromoBannerModel> get banners => _banners;
  SystemSettingsModel get systemSettings => _systemSettings;

  List<ProviderProfileModel> get pendingVerifications =>
      _providers.where((p) => p.verificationStatus == 'pending').toList();

  List<ProviderProfileModel> get pendingProviders => pendingVerifications;

  List<ProviderProfileModel> get verifiedProviders =>
      _providers.where((p) => p.verificationStatus == 'verified').toList();

  int get totalCustomersCount => _totalCustomersCount;
  int get totalBookingsCount => _totalBookingsCount;
  double get totalRevenue => _totalRevenue;
  int get pendingProfileRequestsCount => _pendingProfileRequestsCount;

  Map<String, dynamic> get metrics => {
        'total_users': totalCustomersCount,
        'total_customers': totalCustomersCount,
        'total_providers': _providers.length,
        'pending_verifications': pendingVerifications.length,
        'pending_profile_requests': pendingProfileRequestsCount,
        'total_bookings': totalBookingsCount,
        'total_revenue': totalRevenue,
      };

  Future<void> fetchAdminDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (apiClient == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final metricsData = await apiClient!.get('/admin/metrics');
      if (metricsData is Map<String, dynamic> && metricsData['data'] is Map<String, dynamic>) {
        final m = metricsData['data'] as Map<String, dynamic>;
        _totalCustomersCount = (m['total_customers'] as num?)?.toInt() ?? 0;
        _totalBookingsCount = (m['total_bookings'] as num?)?.toInt() ?? 0;
        _totalRevenue = (m['total_revenue'] as num?)?.toDouble() ?? 0.0;
        _pendingProfileRequestsCount = (m['pending_profile_requests'] as num?)?.toInt() ?? 0;
      }

      final providersData = await apiClient!.get('/admin/providers');
      final list = _extractList(providersData);

      _providers = list
          .map((item) => ProviderProfileModel.fromJson(item as Map<String, dynamic>))
          .toList();

      await Future.wait([
        fetchPendingProfileRequests(),
        fetchAllBookings(),
        fetchCategories(),
        fetchBanners(),
        fetchSystemSettings(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is Map<String, dynamic>) {
      final payload = data['data'] ?? data;
      if (payload is Map<String, dynamic> && payload.containsKey('items')) {
        return payload['items'] as List<dynamic>? ?? const [];
      }
      if (payload is List<dynamic>) return payload;
    }
    if (data is List<dynamic>) return data;
    return const [];
  }

  Future<void> fetchAdminData() => fetchAdminDashboardData();

  // ── Pending Profile Requests ───────────────────────────────────────────────

  Future<void> fetchPendingProfileRequests() async {
    if (apiClient == null) return;
    try {
      final res = await apiClient!.get('/admin/profile-requests');
      final list = _extractList(res);

      _pendingProfileRequests = list
          .map((item) => ProviderProfileRequestModel.fromJson(item as Map<String, dynamic>))
          .toList();
      _pendingProfileRequestsCount = _pendingProfileRequests.length;
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> approveProfileRequest(String requestId) async {
    try {
      if (apiClient != null) {
        await apiClient!.patch('/admin/profile-requests/$requestId/approve');
      }
      _pendingProfileRequests.removeWhere((r) => r.id == requestId);
      _pendingProfileRequestsCount = _pendingProfileRequests.length;
      await fetchAdminDashboardData();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectProfileRequest(String requestId, [String? reason]) async {
    try {
      if (apiClient != null) {
        await apiClient!.patch(
          '/admin/profile-requests/$requestId/reject',
          body: {'reason': reason ?? 'Rejected by admin'},
        );
      }
      _pendingProfileRequests.removeWhere((r) => r.id == requestId);
      _pendingProfileRequestsCount = _pendingProfileRequests.length;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Global Bookings Explorer ──────────────────────────────────────────────

  Future<void> fetchAllBookings([String? status]) async {
    if (apiClient == null) return;
    try {
      var path = '/admin/bookings';
      if (status != null && status.isNotEmpty && status != 'all') {
        path += '?status=$status';
      }
      final res = await apiClient!.get(path);
      final list = _extractList(res);

      _allBookings = list
          .map((item) => BookingModel.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  // ── Categories CRUD ────────────────────────────────────────────────────────

  Future<void> fetchCategories() async {
    if (apiClient == null) return;
    try {
      final res = await apiClient!.get('/admin/categories');
      final list = res is Map<String, dynamic>
          ? (res['data'] as List<dynamic>? ?? const [])
          : (res as List<dynamic>? ?? const []);

      _categories = list
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {
      try {
        final res = await apiClient!.get('/categories');
        final list = res is Map<String, dynamic>
            ? (res['data'] as List<dynamic>? ?? const [])
            : (res as List<dynamic>? ?? const []);

        _categories = list
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<bool> createCategory({required String name, required String iconName, String? description}) async {
    try {
      if (apiClient != null) {
        await apiClient!.post('/admin/categories', body: {
          'name': name,
          'icon_name': iconName,
          if (description != null) 'description': description,
        });
      }
      await fetchCategories();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(String categoryId, {String? name, String? iconName, String? description}) async {
    try {
      if (apiClient != null) {
        await apiClient!.put('/admin/categories/$categoryId', body: {
          if (name != null) 'name': name,
          if (iconName != null) 'icon_name': iconName,
          if (description != null) 'description': description,
        });
      }
      await fetchCategories();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      if (apiClient != null) {
        await apiClient!.delete('/admin/categories/$categoryId');
      }
      _categories.removeWhere((c) => c.id == categoryId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Promo Banners CRUD ─────────────────────────────────────────────────────

  Future<void> fetchBanners() async {
    if (apiClient == null) return;
    try {
      final res = await apiClient!.get('/admin/banners');
      final list = res is Map<String, dynamic>
          ? (res['data'] as List<dynamic>? ?? const [])
          : (res as List<dynamic>? ?? const []);

      _banners = list
          .map((item) => PromoBannerModel.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      try {
        final res = await apiClient!.get('/banners');
        final list = res is Map<String, dynamic>
            ? (res['data'] as List<dynamic>? ?? const [])
            : (res as List<dynamic>? ?? const []);
        _banners = list
            .map((item) => PromoBannerModel.fromJson(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<bool> createBanner(PromoBannerModel banner) async {
    try {
      if (apiClient != null) {
        await apiClient!.post('/admin/banners', body: banner.toJson());
      }
      await fetchBanners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBanner(PromoBannerModel banner) async {
    try {
      if (apiClient != null) {
        await apiClient!.put('/admin/banners/${banner.id}', body: banner.toJson());
      }
      final idx = _banners.indexWhere((b) => b.id == banner.id);
      if (idx != -1) {
        _banners[idx] = banner;
        notifyListeners();
      } else {
        await fetchBanners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBanner(String bannerId) async {
    try {
      if (apiClient != null) {
        await apiClient!.delete('/admin/banners/$bannerId');
      }
      _banners.removeWhere((b) => b.id == bannerId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── System Settings ───────────────────────────────────────────────────────

  Future<void> fetchSystemSettings() async {
    if (apiClient == null) return;
    try {
      final res = await apiClient!.get('/admin/settings');
      final data = res is Map<String, dynamic> ? (res['data'] ?? res) : res;
      if (data is Map<String, dynamic>) {
        _systemSettings = SystemSettingsModel.fromJson(data);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> updateSystemSettings(SystemSettingsModel settings) async {
    try {
      if (apiClient != null) {
        await apiClient!.put('/admin/settings', body: settings.toJson());
      }
      _systemSettings = settings;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Provider Actions ──────────────────────────────────────────────────────

  Future<bool> approveProvider(String providerId) async {
    try {
      if (apiClient != null) {
        await apiClient!.patch('/admin/providers/$providerId/verify');
      }
      final idx = _providers.indexWhere((p) => p.id == providerId);
      if (idx != -1) {
        _providers[idx] = _providers[idx].copyWith(verificationStatus: 'verified');
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectProvider(String providerId, [String? reason]) async {
    try {
      if (apiClient != null) {
        await apiClient!.patch(
          '/admin/providers/$providerId/reject',
          body: {'reason': reason ?? 'Incomplete credentials'},
        );
      }
      final idx = _providers.indexWhere((p) => p.id == providerId);
      if (idx != -1) {
        _providers[idx] = _providers[idx].copyWith(
          verificationStatus: 'rejected',
          rejectionReason: reason ?? 'Incomplete business credentials',
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
