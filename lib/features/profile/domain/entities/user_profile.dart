/// Domain entity — user profile details and app preferences.
/// No JSON logic here. No HTTP imports.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.avatarUrl,
    this.language = 'English',
    this.notificationsEnabled = true,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String? avatarUrl;
  final String language;
  final bool notificationsEnabled;

  UserProfile copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? avatarUrl,
    String? language,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      language: language ?? this.language,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  String toString() => 'UserProfile(id: $id, name: $name)';
}
