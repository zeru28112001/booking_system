/// Domain entity — user profile details and app preferences.
/// No JSON logic here. No HTTP imports.
class SavedLocation {
  const SavedLocation({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String label;
  final String address;
  final double latitude;
  final double longitude;
}

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
    this.savedLocations = const [],
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String? avatarUrl;
  final String language;
  final bool notificationsEnabled;
  final List<SavedLocation> savedLocations;

  UserProfile copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? avatarUrl,
    String? language,
    bool? notificationsEnabled,
    List<SavedLocation>? savedLocations,
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
      savedLocations: savedLocations ?? this.savedLocations,
    );
  }

  @override
  String toString() => 'UserProfile(id: $id, name: $name)';
}
