import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../domain/entities/time_slot.dart';

/// Three-column grid of slots for the chosen day.
/// Taken slots are struck through and inert.
class TimeSlotGrid extends StatelessWidget {
  const TimeSlotGrid({
    super.key,
    required this.slots,
    required this.selectedTime,
    required this.onSelected,
  });

  final List<TimeSlot> slots;
  final String? selectedTime;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppConstants.spaceSm,
      crossAxisSpacing: AppConstants.spaceSm,
      childAspectRatio: 2.4,
      children: [
        for (final slot in slots)
          _SlotCell(
            slot: slot,
            isSelected: slot.time == selectedTime,
            onTap: () => onSelected(slot.time),
          ),
      ],
    );
  }
}

class _SlotCell extends StatelessWidget {
  const _SlotCell({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final TimeSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = slot.isAvailable;
    final selected = available && isSelected;

    return Material(
      color: selected ? AppTheme.primary : AppTheme.surface,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: InkWell(
        onTap: available ? onTap : null,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            color: available ? null : AppTheme.background,
            border: Border.all(
              color: selected
                  ? AppTheme.primary
                  : available
                      ? AppTheme.divider
                      : AppTheme.divider.withAlpha(120),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppFormatters.timeLabel(slot.time),
                style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? AppTheme.onPrimary
                          : available
                              ? AppTheme.onSurface
                              : AppTheme.textHint,
                    ),
              ),
              if (!available) ...[
                const SizedBox(height: 1),
                Text(
                  'Booked',
                  style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: AppTheme.error.withAlpha(180),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
