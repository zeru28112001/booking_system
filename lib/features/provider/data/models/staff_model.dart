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
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'Staff Member',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      isAvailableToday: json['is_available_today'] as bool? ?? true,
      avatarUrl: json['avatar_url'] as String?,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
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
    };
  }
}
