import '../../domain/entities/time_slot.dart';

/// Data-layer DTO — extends TimeSlot and adds JSON (de)serialization.
class TimeSlotModel extends TimeSlot {
  const TimeSlotModel({required super.time, required super.isAvailable});

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      time: (json['time'] as String?) ?? '',
      isAvailable: (json['is_available'] as bool?) ??
          (json['isAvailable'] as bool?) ??
          false,
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time,
        'is_available': isAvailable,
      };
}
