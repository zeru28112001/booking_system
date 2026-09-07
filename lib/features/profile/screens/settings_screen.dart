import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    final notificationsOn = profile?.notificationsEnabled ?? true;
    final currentLanguage = profile?.language ?? 'English';

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferences', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppConstants.spaceSm),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined,
                        color: AppTheme.primary),
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive booking updates & reminders'),
                    activeThumbColor: AppTheme.primary,
                    value: notificationsOn,
                    onChanged: (val) {
                      context
                          .read<ProfileProvider>()
                          .updatePreferences(notificationsEnabled: val);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        const Icon(Icons.language_outlined, color: AppTheme.primary),
                    title: const Text('Language'),
                    subtitle: Text(currentLanguage),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => SimpleDialog(
                          title: const Text('Choose Language'),
                          children: [
                            SimpleDialogOption(
                              onPressed: () {
                                context
                                    .read<ProfileProvider>()
                                    .updatePreferences(language: 'English');
                                Navigator.pop(ctx);
                              },
                              child: const Text('English'),
                            ),
                            SimpleDialogOption(
                              onPressed: () {
                                context
                                    .read<ProfileProvider>()
                                    .updatePreferences(language: 'Myanmar (မြန်မာ)');
                                Navigator.pop(ctx);
                              },
                              child: const Text('Myanmar (မြန်မာ)'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Text('About & Legal', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppConstants.spaceSm),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined,
                        color: AppTheme.primary),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined,
                        color: AppTheme.primary),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded,
                        color: AppTheme.primary),
                    title: const Text('App Version'),
                    subtitle: const Text('v1.0.0 (Build 100)'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
