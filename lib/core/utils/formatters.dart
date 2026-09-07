/// App-wide display formatting — currency, dates, times, durations.
/// Kept dependency-free on purpose; revisit if real localization lands.
class AppFormatters {
  AppFormatters._();

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// 15000 → '15,000 MMK'
  static String currency(int amount) => '${_group(amount)} MMK';

  /// 10000, 50000 → '10,000 – 50,000 MMK'
  static String priceRange(int min, int max) =>
      '${_group(min)} – ${_group(max)} MMK';

  /// '2026-09-12' → 'Sat, 12 Sep 2026'
  static String dateLabel(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${_weekdays[date.weekday - 1]}, ${date.day} '
        '${_months[date.month - 1]} ${date.year}';
  }

  /// '13:00' → '1:00 PM'
  static String timeLabel(String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.parse(parts[0]);
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:${parts[1]} $suffix';
  }

  /// 90 → '1 hr 30 min'
  static String durationLabel(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours hr' : '$hours hr $rest min';
  }

  /// 2026-09-07 → 'Mon'
  static String weekdayShort(DateTime date) => _weekdays[date.weekday - 1];

  /// 2026-09-07 → 'Sep'
  static String monthShort(DateTime date) => _months[date.month - 1];

  /// Local 'yyyy-MM-dd' key. Built from components on purpose —
  /// toIso8601String() would shift the day for UTC-offset timezones.
  static String isoDay(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String _group(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
