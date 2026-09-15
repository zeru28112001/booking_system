import '../../domain/entities/staff.dart';

class StaffModel extends Staff {
  const StaffModel({
    required super.id,
    required super.name,
    required super.role,
    required super.rating,
    required super.isAvailableToday,
    super.avatarUrl,
    super.specialties = const [],
    super.offDays,
    super.shiftStartTime,
    super.shiftEndTime,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'Staff Member',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      isAvailableToday: json['isAvailableToday'] as bool? ??
          json['is_available_today'] as bool? ??
          json['isActive'] as bool? ??
          json['is_active'] as bool? ??
          true,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      offDays: (json['offDays'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      shiftStartTime: json['shiftStartTime'] as String?,
      shiftEndTime: json['shiftEndTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'rating': rating,
      'is_available_today': isAvailableToday,
      'avatar_url': avatarUrl,
      'specialties': specialties,
      'offDays': offDays,
      'shiftStartTime': shiftStartTime,
      'shiftEndTime': shiftEndTime,
    };
  }
}
