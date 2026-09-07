import 'package:flutter/foundation.dart';
import '../domain/entities/provider_sort.dart';
import '../domain/entities/service_provider.dart';
import '../domain/repositories/provider_repository.dart';

/// Provider-list state for one category, plus client-side sorting.
/// Screens never import data/ or call HTTP directly.
class ProviderListProvider extends ChangeNotifier {
  ProviderListProvider({required this._providerRepository});

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
      _providers = await _providerRepository.getProvidersByCategory(categoryId);
      _sort = ProviderSort.recommended;
      _error = null;
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
