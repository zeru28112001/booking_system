import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: AppConstants.spaceXs),
            Text(
              'Last updated: September 25, 2026',
              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            _buildSection(
              theme,
              title: '1. Agreement to Terms',
              content:
                  'By creating an account or accessing Booking System, you agree to be bound by these Terms of Service. If you do not agree with any part of these terms, you may not use our services.',
            ),
            _buildSection(
              theme,
              title: '2. Customer Booking Responsibilities',
              content:
                  'When making appointments through the platform:\n'
                  '• You agree to provide accurate contact information.\n'
                  '• You agree to arrive on time or ensure access for home services.\n'
                  '• Cancellations must be made in advance in accordance with the provider policy.',
            ),
            _buildSection(
              theme,
              title: '3. Service Provider Terms',
              content:
                  'Service providers listed on the platform agree to maintain valid business qualifications, deliver services professionally as advertised, and honor accepted appointments.',
            ),
            _buildSection(
              theme,
              title: '4. Limitation of Liability',
              content:
                  'Booking System acts as a platform connecting customers with service providers. While we review provider accounts, we are not liable for direct disputes arising from service quality or third-party interactions.',
            ),
            _buildSection(
              theme,
              title: '5. Account Termination',
              content:
                  'We reserve the right to suspend or terminate accounts that violate platform policies, engage in fraudulent behavior, or post misleading service listings.',
            ),
            const SizedBox(height: AppConstants.spaceXl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, {required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
