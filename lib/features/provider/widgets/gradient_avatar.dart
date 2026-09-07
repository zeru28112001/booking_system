import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// Gradient initials tile — stands in for a provider photo, since the app
/// bundles no image assets.
class GradientAvatar extends StatelessWidget {
  const GradientAvatar({
    super.key,
    required this.name,
    this.size = 56,
    this.fontSize = 20,
  });

  final String name;
  final double size;
  final double fontSize;

  String get _initials {
    final words =
        name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Text(
        _initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppTheme.onPrimary,
            ),
      ),
    );
  }
}
