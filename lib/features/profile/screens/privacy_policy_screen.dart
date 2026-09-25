import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
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
              title: '1. Introduction',
              content:
                  'Welcome to Booking System. We respect your privacy and are committed to protecting your personal data. This privacy policy informs you about how we look after your personal data when you visit or use our application and tells you about your privacy rights.',
            ),
            _buildSection(
              theme,
              title: '2. Information We Collect',
              content:
                  'We collect and process the following types of information when you use our service:\n'
                  '• Personal Identification: Name, phone number, email address, and profile details.\n'
                  '• Booking Data: Appointment history, preferred services, provider notes, and ratings.\n'
                  '• Location Data: Optional geographic coordinates used for finding nearby service providers.',
            ),
            _buildSection(
              theme,
              title: '3. How We Use Your Data',
              content:
                  'Your data is processed strictly for legitimate operational purposes, including:\n'
                  '• Facilitating and confirming service bookings between customers and providers.\n'
                  '• Sending real-time push notifications, appointment reminders, and status updates.\n'
                  '• Improving system security, performance, and user experience.',
            ),
            _buildSection(
              theme,
              title: '4. Data Security & Protection',
              content:
                  'We implement robust security measures including encrypted transport (HTTPS/TLS) and secure token authentication to safeguard your information against unauthorized access, loss, or misuse.',
            ),
            _buildSection(
              theme,
              title: '5. Contact Us',
              content:
                  'If you have any questions or requests regarding this Privacy Policy or your personal data, please contact our support team at support@bookingsystem.mm or 09 123 456 780.',
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
