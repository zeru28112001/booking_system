import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// Tinted pill for a booking status string.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  /// 'pending' | 'accepted' | 'in_progress' | 'completed' | 'cancelled'
  final String status;

  (Color, String) get _display => switch (status) {
        'accepted' => (AppTheme.info, 'Accepted'),
        'in_progress' => (AppTheme.primary, 'In Progress'),
        'completed' => (AppTheme.secondary, 'Completed'),
        'cancelled' => (AppTheme.error, 'Cancelled'),
        _ => (AppTheme.warning, 'Pending'),
      };

  @override
  Widget build(BuildContext context) {
    final (color, label) = _display;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSm,
        vertical: AppConstants.spaceXs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppConstants.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
