import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

/// Horizontal strip of the next [dayCount] days, each tappable.
/// Chosen over a date picker dialog so the option set stays visible and
/// testable in one tap.
class DateStrip extends StatelessWidget {
  const DateStrip({
    super.key,
    required this.selectedDate,
    required this.onSelected,
    this.dayCount = 14,
  });

  /// 'yyyy-MM-dd'
  final String selectedDate;
  final ValueChanged<String> onSelected;
  final int dayCount;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dayCount,
        separatorBuilder: (_, _) => const SizedBox(width: AppConstants.spaceSm),
        itemBuilder: (context, index) {
          final date = DateTime(today.year, today.month, today.day)
              .add(Duration(days: index));
          final iso = AppFormatters.isoDay(date);
          return _DateChip(
            date: date,
            isToday: index == 0,
            isSelected: iso == selectedDate,
            onTap: () => onSelected(iso),
          );
        },
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = isSelected ? AppTheme.onPrimary : AppTheme.onSurface;

    return Material(
      color: isSelected ? AppTheme.primary : AppTheme.surface,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Container(
          width: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.divider,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isToday ? 'Today' : AppFormatters.weekdayShort(date),
                style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppTheme.onPrimary.withAlpha(220)
                          : AppTheme.textSecondary,
                      fontSize: 11,
                    ),
              ),
              const SizedBox(height: AppConstants.spaceXs),
              Text(
                '${date.day}',
                style: theme.textTheme.titleMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                AppFormatters.monthShort(date),
                style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppTheme.onPrimary.withAlpha(220)
                          : AppTheme.textSecondary,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
