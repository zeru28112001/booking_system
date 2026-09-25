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
    super.servicePrices = const {},
    super.offDays,
    super.shiftStartTime,
    super.shiftEndTime,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    Map<String, int> parsedPrices = {};
    if (json['servicePrices'] is Map) {
      (json['servicePrices'] as Map).forEach((k, v) {
        if (v is num) parsedPrices[k.toString()] = v.toInt();
      });
    } else if (json['service_prices'] is Map) {
      (json['service_prices'] as Map).forEach((k, v) {
        if (v is num) parsedPrices[k.toString()] = v.toInt();
      });
    }

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
      servicePrices: parsedPrices,
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
      'servicePrices': servicePrices,
      'service_prices': servicePrices,
      'offDays': offDays,
      'shiftStartTime': shiftStartTime,
      'shiftEndTime': shiftEndTime,
    };
  }
}
