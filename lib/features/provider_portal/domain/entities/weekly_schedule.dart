/// Domain entity representing a day's working schedule.
class DaySchedule {
  const DaySchedule({
    required this.dayName, // 'Monday', 'Tuesday', etc.
    required this.isOpen,
    required this.startTime, // '09:00'
    required this.endTime,   // '18:00'
  });

  final String dayName;
  final bool isOpen;
  final String startTime;
  final String endTime;

  DaySchedule copyWith({
    String? dayName,
    bool? isOpen,
    String? startTime,
    String? endTime,
  }) {
    return DaySchedule(
      dayName: dayName ?? this.dayName,
      isOpen: isOpen ?? this.isOpen,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

class WeeklySchedule {
  const WeeklySchedule({required this.days});

  final List<DaySchedule> days;
}
