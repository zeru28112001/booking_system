// foundation exports its own `Category` annotation — hide it so the domain
// entity below resolves unambiguously.
import 'package:flutter/foundation.dart' hide Category;
import '../domain/entities/category.dart';
import '../domain/repositories/home_repository.dart';

/// Home state — category discovery.
/// Screens never import data/ or call HTTP directly.
class HomeProvider extends ChangeNotifier {
  HomeProvider({required this._homeRepository});

  final HomeRepository _homeRepository;

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  String? _error;
  List<Category> _categories = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Category> get categories => _categories;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Load the Home category grid (called from HomeScreen initState + retry).
  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      _categories = await _homeRepository.getCategories();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _categories = [];
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
