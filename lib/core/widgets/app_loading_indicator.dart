import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Centered loading indicator using brand primary color.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.size = 40.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 3,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}
