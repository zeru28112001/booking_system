/// Domain entity — one bookable time slot on a given day.
class TimeSlot {
  const TimeSlot({required this.time, required this.isAvailable});

  /// 'HH:mm' (24h)
  final String time;

  final bool isAvailable;

  @override
  String toString() => 'TimeSlot(time: $time, isAvailable: $isAvailable)';
}
