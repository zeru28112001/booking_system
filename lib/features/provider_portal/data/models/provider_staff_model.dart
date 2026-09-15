import '../../domain/entities/provider_staff.dart';

class ProviderStaffModel extends ProviderStaff {
  const ProviderStaffModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.specialties,
    required super.isActive,
    required super.avatarUrl,
    super.offDays,
    super.shiftStartTime,
    super.shiftEndTime,
  });

  factory ProviderStaffModel.fromJson(Map<String, dynamic> json) {
    return ProviderStaffModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isActive: json['isAvailableToday'] as bool? ??
          json['is_available_today'] as bool? ??
          json['isActive'] as bool? ??
          json['is_active'] as bool? ??
          true,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String? ?? '',
      offDays: (json['offDays'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      shiftStartTime: json['shiftStartTime'] as String?,
      shiftEndTime: json['shiftEndTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'specialties': specialties,
      'is_active': isActive,
      'isActive': isActive,
      'isAvailableToday': isActive,
      'is_available_today': isActive,
      'avatar_url': avatarUrl,
      'offDays': offDays,
      'shiftStartTime': shiftStartTime,
      'shiftEndTime': shiftEndTime,
    };
  }

  ProviderStaffModel copyWith({
    String? id,
    String? name,
    String? phone,
    List<String>? specialties,
    bool? isActive,
    String? avatarUrl,
    List<String>? offDays,
    String? shiftStartTime,
    String? shiftEndTime,
  }) {
    return ProviderStaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      specialties: specialties ?? this.specialties,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      offDays: offDays ?? this.offDays,
      shiftStartTime: shiftStartTime ?? this.shiftStartTime,
      shiftEndTime: shiftEndTime ?? this.shiftEndTime,
    );
  }
}
