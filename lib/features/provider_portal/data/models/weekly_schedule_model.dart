import '../../domain/entities/weekly_schedule.dart';

class DayScheduleModel extends DaySchedule {
  const DayScheduleModel({
    required super.dayName,
    required super.isOpen,
    required super.startTime,
    required super.endTime,
  });

  factory DayScheduleModel.fromJson(Map<String, dynamic> json) {
    return DayScheduleModel(
      dayName: json['day_name'] as String? ?? json['dayName'] as String? ?? '',
      isOpen: json['is_open'] as bool? ?? json['isOpen'] as bool? ?? true,
      startTime: json['start_time'] as String? ?? json['startTime'] as String? ?? '09:00',
      endTime: json['end_time'] as String? ?? json['endTime'] as String? ?? '18:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_name': dayName,
      'is_open': isOpen,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

class WeeklyScheduleModel extends WeeklySchedule {
  const WeeklyScheduleModel({required List<DayScheduleModel> super.days});

  factory WeeklyScheduleModel.fromJson(Map<String, dynamic> json) {
    final list = json['days'] as List<dynamic>? ?? const [];
    return WeeklyScheduleModel(
      days: list
          .map((item) => DayScheduleModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': (days as List<DayScheduleModel>).map((d) => d.toJson()).toList(),
    };
  }
}
