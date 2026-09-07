import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// Vertical progress track for a booking: Pending → Accepted → In Progress →
/// Completed. A cancelled booking shows an error banner instead of a track.
class StatusStepper extends StatelessWidget {
  const StatusStepper({super.key, required this.status});

  /// 'pending' | 'accepted' | 'in_progress' | 'completed' | 'cancelled'
  final String status;

  static const _steps = ['pending', 'accepted', 'in_progress', 'completed'];
  static const _labels = ['Pending', 'Accepted', 'In Progress', 'Completed'];

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') return const _CancelledBanner();

    final found = _steps.indexOf(status);
    final current = found < 0 ? 0 : found;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          if (i > 0) _Connector(isDone: i <= current),
          _Step(
            number: i + 1,
            label: _labels[i],
            isDone: i < current,
            isCurrent: i == current,
          ),
        ],
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.label,
    required this.isDone,
    required this.isCurrent,
  });

  final int number;
  final String label;
  final bool isDone;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDone || isCurrent ? AppTheme.primary : AppTheme.divider;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone || isCurrent ? AppTheme.primary : Colors.transparent,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: isDone
              ? const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppTheme.onPrimary,
                )
              : Text(
                  '$number',
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: isCurrent ? AppTheme.onPrimary : AppTheme.textHint,
                        fontWeight: FontWeight.w600,
                      ),
                ),
        ),
        const SizedBox(width: AppConstants.spaceMd),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isDone || isCurrent
                    ? AppTheme.onSurface
                    : AppTheme.textHint,
              ),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.isDone});

  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: Container(
        width: 2,
        height: 28,
        color: isDone ? AppTheme.primary : AppTheme.divider,
      ),
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  const _CancelledBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.error.withAlpha(20),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppTheme.error.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cancel_rounded,
            color: AppTheme.error,
            size: 22,
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              'This booking was cancelled.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.error,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
