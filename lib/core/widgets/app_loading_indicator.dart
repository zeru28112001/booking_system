import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Custom branded loading indicator using Flutter's CircularProgressIndicator.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 48.0,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
          backgroundColor: AppTheme.primary.withAlpha(30),
        ),
      ),
    );
  }
}
