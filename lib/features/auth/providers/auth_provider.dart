import 'package:flutter/foundation.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';

/// Auth state for the entire app.
/// Screens never import data/ or call HTTP directly.
class AuthProvider extends ChangeNotifier {
  AuthProvider({required this._authRepository});

  final AuthRepository _authRepository;

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  String? _error;
  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Check token on app start (called from SplashScreen).
  Future<void> checkAuthState() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authRepository.getStoredUser();
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String phone,
    required String password,
    String role = 'customer',
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.login(
        phone: phone,
        password: password,
        role: role,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    String role = 'customer',
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.register(
        name: name,
        phone: phone,
        password: password,
        role: role,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyFirebasePhone({
    required String idToken,
    String? phone,
    String role = 'customer',
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.verifyFirebasePhone(
        idToken: idToken,
        phone: phone,
        role: role,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
