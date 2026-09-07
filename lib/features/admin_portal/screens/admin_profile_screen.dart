import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:booking_system/features/auth/providers/auth_provider.dart';
import '../providers/admin_portal_provider.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Admin Password & Security'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Super Admin security policy is active.'),
            SizedBox(height: 8),
            Text(
              'To update security tokens or administrative credentials, contact your platform infrastructure team.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminProvider = context.watch<AdminPortalProvider>();
    final metrics = adminProvider.metrics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Account & Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Profile Card
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primary.withAlpha(30),
                    child: const Icon(Icons.admin_panel_settings_rounded, size: 40, color: AppTheme.primary),
                  ),
                  const SizedBox(width: AppConstants.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Administrator',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                          ),
                          child: const Text(
                            'SUPER ADMIN',
                            style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'admin@booklocal.com · 09 000 000 000',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),

            // Platform Governance & Metrics
            Text('Platform Infrastructure', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppConstants.spaceSm),
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                children: [
                  _buildInfoRow(context, label: 'App Version', value: 'v1.0.0+1 (Clean Architecture)'),
                  const Divider(height: 20),
                  _buildInfoRow(context, label: 'Backend API Status', value: 'Mock Engine (Active)'),
                  const Divider(height: 20),
                  _buildInfoRow(context, label: 'Total Registered Providers', value: '${metrics['total_providers'] ?? 0} Shops'),
                  const Divider(height: 20),
                  _buildInfoRow(context, label: 'Pending Verification Queue', value: '${metrics['pending_verifications'] ?? 0} Pending'),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),

            // Security & Controls
            Text('Security & System Controls', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppConstants.spaceSm),
            _buildSettingTile(
              context,
              icon: Icons.shield_outlined,
              title: 'Verification Policy Settings',
              subtitle: 'FR-16 automated document checks and approval rules',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification rules are operating on standard policy.')),
                );
              },
            ),
            _buildSettingTile(
              context,
              icon: Icons.lock_outline_rounded,
              title: 'Security Credentials',
              subtitle: 'Manage admin authentication keys and passwords',
              onTap: () => _showChangePasswordDialog(context),
            ),
            const SizedBox(height: AppConstants.spaceLg),

            // Logout Action
            Text('Account Session', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppConstants.spaceSm),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(color: AppTheme.divider),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppTheme.error),
                title: const Text('Logout Admin Portal', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
                onTap: () async {
                  final auth = context.read<AuthProvider>();
                  final router = GoRouter.of(context);
                  await auth.logout();
                  router.go('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required String label, required String value}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppTheme.divider),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
