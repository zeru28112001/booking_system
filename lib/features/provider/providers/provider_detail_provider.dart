import 'package:flutter/foundation.dart';
import '../domain/entities/service_provider.dart';
import '../domain/repositories/provider_repository.dart';

import '../../../core/network/socket_service.dart';

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
      _initSocket(providerId);
    } catch (e) {
      _error = e.toString();
      _provider = null;
    } finally {
      _setLoading(false);
    }
  }

  void _initSocket(String providerId) {
    final socket = SocketService();
    socket.joinRoom('provider_$providerId');
    socket.removeProviderUpdatedListener(_handleProviderUpdated);
    socket.onProviderUpdated(_handleProviderUpdated);
  }

  void _handleProviderUpdated(dynamic data) {
    if (data == null || _provider == null) return;
    final map = data is Map<String, dynamic> ? data : {};
    final eventProviderId = (map['_id'] ?? map['id'] ?? '').toString();
    if (eventProviderId.isEmpty || eventProviderId == _provider!.id) {
      final isAvailableRaw = map['is_available'] ?? map['isAvailable'];
      final isOpenRaw = map['is_open'] ?? map['isOpen'];
      if (isAvailableRaw != null) {
        final bool isAvail = isAvailableRaw == true || isAvailableRaw == 'true';
        final bool isOpen = isOpenRaw != null ? (isOpenRaw == true || isOpenRaw == 'true') : isAvail;
        _provider = _provider!.copyWith(
          isAvailable: isAvail,
          isOpen: isOpen,
        );
        notifyListeners();
      } else {
        fetchProviderDetail(_provider!.id);
      }
    }
  }

  @override
  void dispose() {
    SocketService().removeProviderUpdatedListener(_handleProviderUpdated);
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
