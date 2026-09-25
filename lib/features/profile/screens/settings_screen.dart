import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleNotificationToggle(
    BuildContext context,
    bool newValue,
    AppLanguageProvider langProvider,
  ) async {
    final profileProvider = context.read<ProfileProvider>();

    if (!newValue) {
      // Show confirmation dialog before turning OFF push notifications
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
          title: Row(
            children: [
              const Icon(Icons.notifications_off_outlined, color: Colors.amber, size: 24),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Text(
                  langProvider.translate('confirm_turn_off_title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          content: Text(
            langProvider.translate('confirm_turn_off_msg'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text(langProvider.translate('cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
              ),
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: Text(langProvider.translate('turn_off')),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await profileProvider.updatePreferences(notificationsEnabled: false);
      }
    } else {
      await profileProvider.updatePreferences(notificationsEnabled: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = context.watch<ProfileProvider>();
    final langProvider = context.watch<AppLanguageProvider>();
    final profile = profileProvider.profile;

    final notificationsOn = profile?.notificationsEnabled ?? true;
    final currentLangLabel = langProvider.isMyanmar ? 'Myanmar (မြန်မာ)' : 'English';

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(langProvider.translate('settings')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(langProvider.translate('preferences'), style: theme.textTheme.titleLarge),
            const SizedBox(height: AppConstants.spaceSm),
            Material(
              color: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                side: const BorderSide(color: AppTheme.divider),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined,
                        color: AppTheme.primary),
                    title: Text(langProvider.translate('push_notifications')),
                    subtitle: Text(langProvider.translate('push_notif_desc')),
                    activeThumbColor: AppTheme.primary,
                    value: notificationsOn,
                    onChanged: (val) => _handleNotificationToggle(context, val, langProvider),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        const Icon(Icons.language_outlined, color: AppTheme.primary),
                    title: Text(langProvider.translate('language')),
                    subtitle: Text(currentLangLabel),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => SimpleDialog(
                          title: Text(langProvider.translate('choose_language')),
                          children: [
                            SimpleDialogOption(
                              onPressed: () {
                                langProvider.setLanguage('en');
                                context
                                    .read<ProfileProvider>()
                                    .updatePreferences(language: 'English');
                                Navigator.pop(ctx);
                              },
                              child: Row(
                                children: [
                                  const Text('🇬🇧 ', style: TextStyle(fontSize: 18)),
                                  Text(langProvider.translate('english')),
                                  if (!langProvider.isMyanmar)
                                    const Spacer(),
                                  if (!langProvider.isMyanmar)
                                    const Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            SimpleDialogOption(
                              onPressed: () {
                                langProvider.setLanguage('my');
                                context
                                    .read<ProfileProvider>()
                                    .updatePreferences(language: 'Myanmar (မြန်မာ)');
                                Navigator.pop(ctx);
                              },
                              child: Row(
                                children: [
                                  const Text('🇲🇲 ', style: TextStyle(fontSize: 18)),
                                  Text(langProvider.translate('myanmar')),
                                  if (langProvider.isMyanmar)
                                    const Spacer(),
                                  if (langProvider.isMyanmar)
                                    const Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
                                ],
                              ),
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
            Text(langProvider.translate('about_legal'), style: theme.textTheme.titleLarge),
            const SizedBox(height: AppConstants.spaceSm),
            Material(
              color: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                side: const BorderSide(color: AppTheme.divider),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined,
                        color: AppTheme.primary),
                    title: Text(langProvider.translate('privacy_policy')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/privacy-policy'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined,
                        color: AppTheme.primary),
                    title: Text(langProvider.translate('terms_of_service')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/terms-of-service'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded,
                        color: AppTheme.primary),
                    title: Text(langProvider.translate('app_version')),
                    subtitle: const Text('v1.0.1 (Build 3)'),
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
