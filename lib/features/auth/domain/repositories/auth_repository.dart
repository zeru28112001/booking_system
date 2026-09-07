import '../entities/user.dart';

/// Abstract auth repository contract.
/// Providers depend only on this interface, never on the impl.
abstract class AuthRepository {
  /// Login with phone + password → returns authenticated User.
  Future<User> login({
    required String phone,
    required String password,
  });

  /// Register a new customer account → returns authenticated User.
  Future<User> register({
    required String name,
    required String phone,
    required String password,
  });

  /// Logout — clears stored token.
  Future<void> logout();

  /// Returns stored User if a valid token exists, otherwise null.
  Future<User?> getStoredUser();
}
