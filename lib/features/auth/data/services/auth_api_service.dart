import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Handles all auth HTTP calls.
/// Returns typed models — no entities, no notifyListeners.
class AuthApiService {
  const AuthApiService({required this._apiClient});

  final ApiClient _apiClient;

  /// POST /auth/login
  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    final data = await _apiClient.post('/auth/login', body: {
      'phone': phone,
      'password': password,
    }) as Map<String, dynamic>;

    return UserModel.fromJson(data);
  }

  /// POST /auth/register
  Future<UserModel> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    final data = await _apiClient.post('/auth/register', body: {
      'name': name,
      'phone': phone,
      'password': password,
      'role': 'customer', // MVP: customer only
    }) as Map<String, dynamic>;

    return UserModel.fromJson(data);
  }

  /// POST /auth/logout
  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
  }
}
