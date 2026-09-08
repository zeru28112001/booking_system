import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_theme.dart';

/// Animated step progress widget for booking status tracking.
class AnimatedBookingStepper extends StatefulWidget {
  const AnimatedBookingStepper({
    super.key,
    required this.status,
  });

  /// Status string: 'pending', 'accepted', 'completed', 'cancelled'
  final String status;

  @override
  State<AnimatedBookingStepper> createState() => _AnimatedBookingStepperState();
}

class _AnimatedBookingStepperState extends State<AnimatedBookingStepper>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
    final activeStep = _getStepIndex(widget.status);
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
          Row(
            children: List.generate(steps.length, (index) {
              final isCompleted = index < activeStep;
              final isCurrent = index == activeStep;

              return Expanded(
                child: Row(
                  children: [
                    // Step circle icon
                    ScaleTransition(
                      scale: isCurrent ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted || isCurrent
                              ? AppTheme.primary
                              : AppTheme.divider.withAlpha(120),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary.withAlpha(100),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          steps[index]['icon'] as IconData,
                          size: 18,
                          color: isCompleted || isCurrent
                              ? AppTheme.onPrimary
                              : AppTheme.textHint,
                        ),
                      ),
                    ),
                    // Connector line (unless last step)
                    if (index < steps.length - 1)
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 3,
                              color: AppTheme.divider.withAlpha(120),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOutCubic,
                              height: 3,
                              width: isCompleted
                                  ? double.infinity
                                  : (isCurrent ? 50 : 0),
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final isCurrent = index == activeStep;
              final isCompleted = index <= activeStep;
              return SizedBox(
                width: 70,
                child: Text(
                  steps[index]['title'] as String,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCompleted ? AppTheme.primary : AppTheme.textHint,
                      ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
