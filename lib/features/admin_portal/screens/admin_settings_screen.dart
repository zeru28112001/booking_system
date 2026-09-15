import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/models/system_settings_model.dart';
import '../providers/admin_portal_provider.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isMaintenanceMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<AdminPortalProvider>();
      provider.fetchSystemSettings().then((_) {
        if (mounted) {
          final s = provider.systemSettings;
          _phoneController.text = s.supportPhone;
          _emailController.text = s.supportEmail;
          setState(() {
            _isMaintenanceMode = s.isMaintenanceMode;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    final updated = SystemSettingsModel(
      supportPhone: phone,
      supportEmail: email,
      isMaintenanceMode: _isMaintenanceMode,
    );

    final admin = context.read<AdminPortalProvider>();
    final ok = await admin.updateSystemSettings(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'System settings saved successfully!' : 'Failed to update settings'),
          backgroundColor: ok ? AppTheme.success : AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('System Controls & Settings'),
      ),
      body: Consumer<AdminPortalProvider>(
        builder: (context, admin, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer & Provider Support Contact', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppConstants.spaceSm),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Support Phone Helpline',
                      hintText: 'e.g. 09 123 456 780',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter support phone' : null,
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Support Email Address',
                      hintText: 'e.g. support@bookingsystem.mm',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter support email' : null,
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  Text('System Operational Mode', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppConstants.spaceSm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Platform Maintenance Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Temporarily pause customer booking transactions for scheduled maintenance'),
                    value: _isMaintenanceMode,
                    activeColor: AppTheme.warning,
                    onChanged: (val) => setState(() => _isMaintenanceMode = val),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save System Settings'),
                    onPressed: _saveSettings,
                  ),
                  const SizedBox(height: AppConstants.spaceXl),

                  const Divider(),
                  const SizedBox(height: AppConstants.spaceLg),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                    label: const Text('Logout Admin Session', style: TextStyle(color: AppTheme.error)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.error)),
                    onPressed: () async {
                      final authProvider = context.read<AuthProvider>();
                      final router = GoRouter.of(context);
                      await authProvider.logout();
                      router.go('/login');
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
