import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
// AppTheme.text not needed — using theme.textTheme directly

/// Shown when the admin has enabled Platform Maintenance Mode.
/// Blocks customers and providers from using the app.
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with animated glow
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withAlpha(20),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.warning.withAlpha(80),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    size: 60,
                    color: AppTheme.warning,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Under Maintenance',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "We're currently performing scheduled maintenance to improve your experience.\n\nPlease check back shortly.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.warning.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded,
                          color: AppTheme.warning, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Estimated downtime: A few minutes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
