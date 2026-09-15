import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';

/// Concrete implementation of AuthRepository.
/// Calls AuthApiService, maps model → entity, persists token.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.authApiService,
    required this.apiClient,
  });

  final AuthApiService authApiService;
  final ApiClient apiClient;

  static const _prefKeyUser = 'stored_user';

  // ── AuthRepository ────────────────────────────────────────────────────────

  @override
  Future<User> login({
    required String phone,
    required String password,
    String role = 'customer',
  }) async {
    final model = await authApiService.login(phone: phone, password: password);
    await _persistUser(model);
    apiClient.setAuthToken(model.token);
    return model;
  }

  @override
  Future<User> register({
    required String name,
    required String phone,
    required String password,
    String role = 'customer',
  }) async {
    final model = await authApiService.register(
      name: name,
      phone: phone,
      password: password,
      role: role,
    );
    await _persistUser(model);
    apiClient.setAuthToken(model.token);
    return model;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyUser);
    apiClient.clearAuthToken();
    try {
      await authApiService.logout();
    } catch (_) {
      // Swallow — local logout always succeeds
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
      apiClient.setAuthToken(model.token);
      return model;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User> verifyFirebasePhone({
    required String idToken,
    String? phone,
    String role = 'customer',
  }) async {
    final model = await authApiService.verifyFirebasePhone(
      idToken: idToken,
      phone: phone,
      role: role,
    );
    await _persistUser(model);
    apiClient.setAuthToken(model.token);
    return model;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _persistUser(UserModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyUser, jsonEncode(model.toJson()));
  }
}
