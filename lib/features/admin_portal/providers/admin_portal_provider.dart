import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../provider_portal/data/models/provider_profile_model.dart';
import '../data/models/promo_banner_model.dart';

class AdminPortalProvider extends ChangeNotifier {
  AdminPortalProvider({this.apiClient});

  final ApiClient? apiClient;

  bool _isLoading = false;
  String? _error;

  List<ProviderProfileModel> _providers = [];
  List<PromoBannerModel> _banners = [];
  int _totalCustomersCount = 0;
  int _totalBookingsCount = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProviderProfileModel> get providers => _providers;
  List<PromoBannerModel> get banners => _banners;

  List<ProviderProfileModel> get pendingVerifications =>
      _providers.where((p) => p.verificationStatus == 'pending').toList();

  List<ProviderProfileModel> get pendingProviders => pendingVerifications;

  List<ProviderProfileModel> get verifiedProviders =>
      _providers.where((p) => p.verificationStatus == 'verified').toList();

  int get totalCustomersCount => _totalCustomersCount;
  int get totalBookingsCount => _totalBookingsCount;

  Map<String, dynamic> get metrics => {
        'total_users': totalCustomersCount,
        'total_providers': _providers.length,
        'pending_verifications': pendingVerifications.length,
        'total_bookings': totalBookingsCount,
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
      }

      final providersData = await apiClient!.get('/admin/providers');
      final list = providersData is Map<String, dynamic>
          ? (providersData['data'] as List<dynamic>? ?? const [])
          : (providersData as List<dynamic>? ?? const []);

      _providers = list
          .map((item) => ProviderProfileModel.fromJson(item as Map<String, dynamic>))
          .toList();

      await fetchBanners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAdminData() => fetchAdminDashboardData();

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
      // Fallback to public endpoint if admin endpoint fails
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

  // FR-16: Admin Verification Approval
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

  // FR-16: Admin Verification Rejection
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

