/// Domain entity — the app's canonical shape of a User.
/// No JSON logic here. No HTTP imports.
class User {
  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.token,
  });

  final String id;
  final String name;
  final String phone;
  final String role; // 'customer' | 'provider' | 'admin'
  final String token;

  @override
  String toString() => 'User(id: $id, name: $name, phone: $phone, role: $role)';
}
