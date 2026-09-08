import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'animations/app_scale_button.dart';

/// Primary full-width button with optional loading state and tap scale animation.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppScaleButton(
      onTap: isLoading ? null : onPressed,
      child: AnimatedOpacity(
        opacity: (onPressed == null && !isLoading) ? 0.6 : 1.0,
        duration: AppConstants.durationFast,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: AppConstants.spaceSm),
                    ],
                    Text(label),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Outlined variant — same dimensions, transparent background and tap scale animation.
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppScaleButton(
      onTap: onPressed,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: AppConstants.spaceSm),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}
