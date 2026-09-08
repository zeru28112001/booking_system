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

  /// '13:00' or '01:00 PM' or '9:00 AM' → '1:00 PM' / '9:00 AM'
  static String timeLabel(String hhmm) {
    if (hhmm.isEmpty) return '';
    final trimmed = hhmm.trim();
    final upper = trimmed.toUpperCase();
    if (upper.endsWith('AM') || upper.endsWith('PM')) {
      final spaceSplit = trimmed.split(' ');
      final timeParts = spaceSplit[0].split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]);
        if (hour != null) {
          final hour12 = hour % 12 == 0 ? (hour == 0 ? 12 : hour) : (hour > 12 ? hour - 12 : hour);
          return '$hour12:${timeParts[1]} ${spaceSplit[1].toUpperCase()}';
        }
      }
      return trimmed;
    }
    final parts = trimmed.split(':');
    if (parts.length < 2) return trimmed;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minuteParts = parts[1].split(' ');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$hour12:${minuteParts[0]} $suffix';
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
