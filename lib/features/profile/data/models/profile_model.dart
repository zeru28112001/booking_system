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
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: (json['id'] ?? 'user_1').toString(),
      name: (json['name'] as String?) ?? 'Khin Su Su',
      phone: (json['phone'] as String?) ?? '09 987 654 321',
      email: (json['email'] as String?) ?? 'khinsusu@gmail.com',
      address: (json['address'] as String?) ?? 'No. 42, Kabar Aye Pagoda Rd, Mayangone',
      avatarUrl: json['avatar_url'] as String?,
      language: (json['language'] as String?) ?? 'English',
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'avatar_url': avatarUrl,
      'language': language,
      'notifications_enabled': notificationsEnabled,
    };
  }
}
