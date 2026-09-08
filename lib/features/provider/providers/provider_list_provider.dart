import 'package:flutter/foundation.dart';
import '../domain/entities/provider_sort.dart';
import '../domain/entities/service_provider.dart';
import '../domain/repositories/provider_repository.dart';

import '../../../core/network/socket_service.dart';

/// Provider-list state for one category, plus client-side sorting.
/// Screens never import data/ or call HTTP directly.
class ProviderListProvider extends ChangeNotifier {
  ProviderListProvider({required this._providerRepository}) {
    _initSocket();
  }

  final ProviderRepository _providerRepository;

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  String? _error;
  List<ServiceProvider> _providers = [];
  ProviderSort _sort = ProviderSort.recommended;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ServiceProvider> get providers => _providers;
  ProviderSort get sortOption => _sort;

  void _initSocket() {
    SocketService().removeProviderUpdatedListener(_handleProviderUpdated);
    SocketService().onProviderUpdated(_handleProviderUpdated);
  }

  void _handleProviderUpdated(dynamic data) {
    if (data == null || _providers.isEmpty) return;
    final map = data is Map<String, dynamic> ? data : {};
    final updatedId = (map['_id'] ?? map['id'] ?? '').toString();
    final updatedShopName = (map['shopName'] ?? map['name'] ?? '').toString().trim().toLowerCase();

    final index = _providers.indexWhere((p) {
      final pid = p.id.toString();
      final pname = p.name.trim().toLowerCase();
      return (updatedId.isNotEmpty && pid == updatedId) ||
             (updatedShopName.isNotEmpty && pname == updatedShopName);
    });

    if (index != -1) {
      final isAvailableRaw = map['is_available'] ?? map['isAvailable'];
      final isOpenRaw = map['is_open'] ?? map['isOpen'];

      final bool isAvail = isAvailableRaw != null
          ? (isAvailableRaw == true || isAvailableRaw == 'true')
          : false;
      final bool isOpen = isOpenRaw != null
          ? (isOpenRaw == true || isOpenRaw == 'true')
          : isAvail;

      debugPrint('⚡️ [ProviderListProvider] Dynamic update for ${_providers[index].name}: isAvailable=$isAvail, isOpen=$isOpen');

      _providers[index] = _providers[index].copyWith(
        isAvailable: isAvail,
        isOpen: isOpen,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    SocketService().removeProviderUpdatedListener(_handleProviderUpdated);
    super.dispose();
  }

  /// Fetch order preserved; sorting happens on a copy so 'recommended'
  /// (the seed order) always stays recoverable.
  List<ServiceProvider> get sortedProviders {
    final sorted = List.of(_providers);
    switch (_sort) {
      case ProviderSort.recommended:
        break;
      case ProviderSort.topRated:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
      case ProviderSort.nearest:
        sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      case ProviderSort.lowestPrice:
        sorted.sort((a, b) => a.priceMin.compareTo(b.priceMin));
    }
    return sorted;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> fetchProviders(String categoryId) async {
    _setLoading(true);
    try {
      _providers = List<ServiceProvider>.from(
        await _providerRepository.getProvidersByCategory(categoryId),
      );
      _sort = ProviderSort.recommended;
      _error = null;
      _initSocket();
    } catch (e) {
      _error = e.toString();
      _providers = [];
    } finally {
      _setLoading(false);
    }
  }

  void setSort(ProviderSort sort) {
    _sort = sort;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
