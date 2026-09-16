import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../../provider/widgets/gradient_avatar.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('My Profile'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.profile == null) {
            return const AppLoadingIndicator();
          }

          if (provider.error != null && provider.profile == null) {
            return AppErrorState(
              message: provider.error!,
              onRetry: () => context.read<ProfileProvider>().fetchProfile(),
            );
          }

          final profile = provider.profile;
          if (profile == null) {
            return AppEmptyState(
              icon: Icons.person_off_outlined,
              title: 'Profile not found',
              subtitle: 'Could not load your account profile.',
              actionLabel: 'Retry',
              onAction: () => context.read<ProfileProvider>().fetchProfile(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            child: Column(
              children: [
                const SizedBox(height: AppConstants.spaceSm),
                Container(
                  padding: const EdgeInsets.all(AppConstants.spaceLg),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Row(
                    children: [
                      GradientAvatar(name: profile.name, size: 64, fontSize: 24),
                      const SizedBox(width: AppConstants.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profile.phone,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                            Text(
                              profile.email,
                              style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                if (context.watch<AuthProvider>().currentUser?.role == 'admin') ...[
                  _ProfileMenuItem(
                    icon: Icons.admin_panel_settings_rounded,
                    title: 'Switch to Admin Portal',
                    subtitle: 'Manage platform metrics, providers & bookings',
                    iconColor: AppTheme.primary,
                    onTap: () => context.go('/admin-dashboard'),
                  ),
                ] else if (context.watch<AuthProvider>().currentUser?.role == 'provider') ...[
                  _ProfileMenuItem(
                    icon: Icons.storefront_rounded,
                    title: 'Switch to Provider Portal',
                    subtitle: 'Manage shop schedule, services & earnings',
                    iconColor: AppTheme.primary,
                    onTap: () => context.go('/provider-dashboard'),
                  ),
                ],
                _ProfileMenuItem(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  subtitle: 'Update your name & email',
                  onTap: () => context.push('/edit-profile'),
                ),
                _ProfileMenuItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'My Bookings',
                  subtitle: 'View upcoming and past appointments',
                  onTap: () => context.push('/bookings'),
                ),
                _ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'Language, notifications & app preferences',
                  onTap: () => context.push('/settings'),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                _ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  textColor: AppTheme.error,
                  iconColor: AppTheme.error,
                  onTap: () async {
                    final authProvider = context.read<AuthProvider>();
                    final router = GoRouter.of(context);
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Logout?'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: AppTheme.error),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true && mounted) {
                      await authProvider.logout();
                      router.go('/login');
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor ?? AppTheme.primary, size: 24),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                              color: textColor ?? AppTheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
