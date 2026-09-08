// foundation exports its own `Category` annotation — hide it so the domain
// entity below resolves unambiguously.
import 'package:flutter/foundation.dart' hide Category;
import '../../admin_portal/data/models/promo_banner_model.dart';
import '../domain/entities/category.dart';
import '../domain/repositories/home_repository.dart';

/// Home state — category discovery & banners.
/// Screens never import data/ or call HTTP directly.
class HomeProvider extends ChangeNotifier {
  HomeProvider({required this._homeRepository});

  final HomeRepository _homeRepository;

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  String? _error;
  List<Category> _categories = [];
  List<PromoBannerModel> _banners = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Category> get categories => _categories;
  List<PromoBannerModel> get banners => _banners;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Load the Home category grid and promo banners.
  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _homeRepository.getCategories(),
        _homeRepository.getBanners().catchError((_) => <PromoBannerModel>[]),
      ]);
      _categories = results[0] as List<Category>;
      final fetchedBanners = results[1] as List<PromoBannerModel>;
      
      // Filter active banners and sort by sortOrder ascending
      _banners = fetchedBanners.where((b) => b.isActive).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      _error = null;
    } catch (e) {
      _error = e.toString();
      _categories = [];
      _banners = [];
    } finally {
      _setLoading(false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
