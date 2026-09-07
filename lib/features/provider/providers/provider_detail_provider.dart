import 'package:flutter/foundation.dart';
import '../domain/entities/service_provider.dart';
import '../domain/repositories/provider_repository.dart';

/// Single-provider state for the detail screen.
/// Screens never import data/ or call HTTP directly.
class ProviderDetailProvider extends ChangeNotifier {
  ProviderDetailProvider({required this._providerRepository});

  final ProviderRepository _providerRepository;

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  String? _error;
  ServiceProvider? _provider;

  bool get isLoading => _isLoading;
  String? get error => _error;
  ServiceProvider? get provider => _provider;

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> fetchProviderDetail(String providerId) async {
    _setLoading(true);
    try {
      _provider = await _providerRepository.getProviderDetail(providerId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _provider = null;
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
