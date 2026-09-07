import 'package:flutter/foundation.dart';
import '../../provider_portal/data/models/provider_profile_model.dart';

class AdminPortalProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  final List<ProviderProfileModel> _providers = [
    const ProviderProfileModel(
      id: 'prov_pending_01',
      shopName: 'Royal Beauty & Hair Spa',
      categoryName: 'Beauty & Salon',
      description: 'Luxury hair cuts, styling, coloring & spa treatments.',
      address: 'No. 15, Pyay Rd, Mayangone, Yangon',
      phone: '09 777 666 555',
      isAvailable: true,
      verificationStatus: 'pending',
      rating: 5.0,
      reviewCount: 0,
      imageUrl: 'https://picsum.photos/400/300?random=20',
    ),
    const ProviderProfileModel(
      id: 'prov_pending_02',
      shopName: 'CleanPro Home Services',
      categoryName: 'House Cleaning',
      description: 'Professional residential & office deep cleaning.',
      address: 'No. 102, Lower Kyeemyindaing Rd',
      phone: '09 888 444 222',
      isAvailable: true,
      verificationStatus: 'pending',
      rating: 5.0,
      reviewCount: 0,
      imageUrl: 'https://picsum.photos/400/300?random=21',
    ),
    const ProviderProfileModel(
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
    ),
  ];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProviderProfileModel> get providers => _providers;

  List<ProviderProfileModel> get pendingVerifications =>
      _providers.where((p) => p.verificationStatus == 'pending').toList();

  List<ProviderProfileModel> get pendingProviders => pendingVerifications;

  List<ProviderProfileModel> get verifiedProviders =>
      _providers.where((p) => p.verificationStatus == 'verified').toList();

  int get totalCustomersCount => 148;
  int get totalBookingsCount => 382;

  Map<String, dynamic> get metrics => {
        'total_users': totalCustomersCount,
        'total_providers': _providers.length,
        'pending_verifications': pendingVerifications.length,
        'total_bookings': totalBookingsCount,
      };

  Future<void> fetchAdminDashboardData() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAdminData() => fetchAdminDashboardData();

  // FR-16: Admin Verification Approval
  Future<bool> approveProvider(String providerId) async {
    final idx = _providers.indexWhere((p) => p.id == providerId);
    if (idx != -1) {
      _providers[idx] = _providers[idx].copyWith(verificationStatus: 'verified');
      notifyListeners();
      return true;
    }
    return false;
  }

  // FR-16: Admin Verification Rejection
  Future<bool> rejectProvider(String providerId, [String? reason]) async {
    final idx = _providers.indexWhere((p) => p.id == providerId);
    if (idx != -1) {
      _providers[idx] = _providers[idx].copyWith(
        verificationStatus: 'rejected',
        rejectionReason: reason ?? 'Incomplete business credentials',
      );
      notifyListeners();
      return true;
    }
    return false;
  }
}
