import '../../domain/entities/user.dart';

/// Data-layer DTO — extends User and adds JSON (de)serialization.
/// Screens and providers never import this class.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.role,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Unwrap nested `user` key if present (e.g. { "user": {...}, "token": "..." })
    final userData = json['user'] as Map<String, dynamic>? ?? json;
    return UserModel(
      id: (userData['id'] ?? '').toString(),
      name: (userData['name'] as String?) ?? '',
      phone: (userData['phone'] as String?) ?? '',
      role: (userData['role'] as String?) ?? 'customer',
      token: (json['token'] as String?) ?? (userData['token'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role,
        'token': token,
      };
}
