import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_theme.dart';

/// Animated step progress widget for booking status tracking.
class AnimatedBookingStepper extends StatelessWidget {
  const AnimatedBookingStepper({
    super.key,
    required this.status,
  });

  /// Status string: 'pending', 'accepted', 'completed', 'cancelled'
  final String status;

  int _getStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'accepted':
      case 'in_progress':
        return 1;
      case 'completed':
        return 2;
      case 'cancelled':
        return -1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeStep = _getStepIndex(status);
    final isCancelled = activeStep == -1;

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: AppTheme.error.withAlpha(15),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppTheme.error.withAlpha(50)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: AppTheme.error, size: 28),
            const SizedBox(width: AppConstants.spaceSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Booking Cancelled',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'This service request was cancelled.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.error.withAlpha(200),
                      ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final steps = [
      {'title': 'Pending', 'icon': Icons.hourglass_top_rounded},
      {'title': 'Confirmed', 'icon': Icons.task_alt_rounded},
      {'title': 'Completed', 'icon': Icons.verified_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceLg,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppTheme.onSurface.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Step Icons Row with Connector Lines
          Row(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                SizedBox(
                  width: 70,
                  child: Center(
                    child: i == activeStep
                        ? _PulsingStep(
                            icon: steps[i]['icon'] as IconData,
                            isActive: true,
                            isCompleted: true,
                          )
                        : _PulsingStep(
                            icon: steps[i]['icon'] as IconData,
                            isActive: false,
                            isCompleted: i < activeStep,
                          ),
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic,
                      height: 3,
                      color: i < activeStep
                          ? AppTheme.primary
                          : AppTheme.divider.withAlpha(120),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          // Step Titles Row aligned with Icons
          Row(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                SizedBox(
                  width: 70,
                  child: Text(
                    steps[i]['title'] as String,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight:
                              i == activeStep ? FontWeight.w700 : FontWeight.w500,
                          color: i <= activeStep
                              ? AppTheme.primary
                              : AppTheme.textHint,
                        ),
                  ),
                ),
                if (i < steps.length - 1) const Expanded(child: SizedBox()),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// A single step circle that pulses when active using TweenAnimationBuilder
/// (no AnimationController needed — avoids layout-phase assertions).
class _PulsingStep extends StatelessWidget {
  const _PulsingStep({
    required this.icon,
    required this.isActive,
    required this.isCompleted,
  });

  final IconData icon;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? AppTheme.primary : AppTheme.divider.withAlpha(120),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isCompleted ? AppTheme.onPrimary : AppTheme.textHint,
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.12),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primary,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withAlpha(100),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppTheme.onPrimary),
      ),
    );
  }
}
