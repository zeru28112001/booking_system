import '../../domain/entities/provider_staff.dart';

class ProviderStaffModel extends ProviderStaff {
  const ProviderStaffModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.specialties,
    required super.isActive,
    required super.avatarUrl,
  });

  factory ProviderStaffModel.fromJson(Map<String, dynamic> json) {
    return ProviderStaffModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'specialties': specialties,
      'is_active': isActive,
      'avatar_url': avatarUrl,
    };
  }

  ProviderStaffModel copyWith({
    String? id,
    String? name,
    String? phone,
    List<String>? specialties,
    bool? isActive,
    String? avatarUrl,
  }) {
    return ProviderStaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      specialties: specialties ?? this.specialties,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
