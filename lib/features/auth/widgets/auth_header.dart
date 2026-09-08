import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

/// Reusable logo + title block used at the top of all auth screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showLogo = true,
  });

  final String title;
  final String? subtitle;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showLogo) ...[
          // App logo mark
          SizedBox(
            height: 80,
            child: Image.asset(
              'assets/images/app_logo.png',
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
        ],
        Text(
          title,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
