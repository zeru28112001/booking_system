import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';

/// Concrete implementation of AuthRepository.
/// Calls AuthApiService, maps model → entity, persists token.
///
/// Set [useMock] to true during Phase 1 / offline development.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._authApiService,
    required this._apiClient,
    this.useMock = false,
  });

  final AuthApiService _authApiService;
  final ApiClient _apiClient;
  final bool useMock;

  static const _prefKeyUser = 'stored_user';

  // ── AuthRepository ────────────────────────────────────────────────────────

  @override
  Future<User> login({required String phone, required String password}) async {
    if (useMock) return _mockLogin(phone: phone, password: password);

    final model = await _authApiService.login(phone: phone, password: password);
    await _persistUser(model);
    _apiClient.setAuthToken(model.token);
    return model;
  }

  @override
  Future<User> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    if (useMock) return _mockRegister(name: name, phone: phone);

    final model = await _authApiService.register(
      name: name,
      phone: phone,
      password: password,
    );
    await _persistUser(model);
    _apiClient.setAuthToken(model.token);
    return model;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyUser);
    _apiClient.clearAuthToken();
    if (!useMock) {
      try {
        await _authApiService.logout();
      } catch (_) {
        // Swallow — local logout always succeeds
      }
    }
  }

  @override
  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKeyUser);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final model = UserModel.fromJson(json);
      _apiClient.setAuthToken(model.token);
      return model;
    } catch (_) {
      return null;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _persistUser(UserModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyUser, jsonEncode(model.toJson()));
  }

  // ── Mock responses ────────────────────────────────────────────────────────

  Future<User> _mockLogin({
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate latency
    return UserModel(
      id: '1',
      name: 'Demo Customer',
      phone: phone,
      role: 'customer',
      token: 'mock-token-12345',
    );
  }

  Future<User> _mockRegister({
    required String name,
    required String phone,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: '2',
      name: name,
      phone: phone,
      role: 'customer',
      token: 'mock-token-67890',
    );
  }
}
