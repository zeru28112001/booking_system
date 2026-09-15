import '../../domain/entities/user_profile.dart';

class ProfileModel extends UserProfile {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.address,
    super.avatarUrl,
    super.language,
    super.notificationsEnabled,
    super.savedLocations = const [],
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: (json['id'] ?? 'user_1').toString(),
      name: (json['name'] as String?) ?? 'Khin Su Su',
      phone: (json['phone'] as String?) ?? '09 987 654 321',
      email: (json['email'] as String?) ?? 'khinsusu@gmail.com',
      address: (json['address'] as String?) ?? 'No. 42, Kabar Aye Pagoda Rd, Mayangone',
      avatarUrl: json['avatarUrl'] as String?,
      language: (json['language'] as String?) ?? 'English',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      savedLocations: (json['savedLocations'] as List<dynamic>?)
              ?.map((e) => _parseSavedLocation(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static SavedLocation _parseSavedLocation(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>?;
    final coords = loc?['coordinates'] as List<dynamic>?;
    return SavedLocation(
      id: (json['_id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      latitude: coords != null && coords.length > 1 ? (coords[1] as num).toDouble() : 0.0,
      longitude: coords != null && coords.isNotEmpty ? (coords[0] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'avatarUrl': avatarUrl,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'savedLocations': savedLocations.map((e) => {
        'label': e.label,
        'address': e.address,
        'location': {
          'type': 'Point',
          'coordinates': [e.longitude, e.latitude]
        }
      }).toList(),
    };
  }
}
