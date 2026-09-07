import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/admin_portal_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminPortalProvider>().fetchAdminDashboardData();
    });
  }

  void _showRejectDialog(BuildContext context, String providerId, String shopName) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reject $shopName?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please state the reason for verification rejection:'),
            const SizedBox(height: AppConstants.spaceSm),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g. Invalid business license or address',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              context.read<AdminPortalProvider>().rejectProvider(
                    providerId,
                    reasonController.text.trim(),
                  );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Verification rejected for $shopName')),
              );
            },
            child: const Text('Reject Verification'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Admin Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
            tooltip: 'Logout Admin',
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final router = GoRouter.of(context);
              await authProvider.logout();
              router.go('/login');
            },
          ),
        ],
      ),
      body: Consumer<AdminPortalProvider>(
        builder: (context, admin, _) {
          if (admin.isLoading) {
            return const AppLoadingIndicator();
          }

          final pending = admin.pendingVerifications;
          final allProviders = admin.providers;

          return RefreshIndicator(
            onRefresh: () => admin.fetchAdminDashboardData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // System Metrics Cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppConstants.spaceSm,
                    mainAxisSpacing: AppConstants.spaceSm,
                    childAspectRatio: 1.8,
                    children: [
                      _buildMetricCard(
                        context,
                        title: 'Total Customers',
                        value: '${admin.totalCustomersCount}',
                        icon: Icons.people_outline_rounded,
                        color: AppTheme.primary,
                      ),
                      _buildMetricCard(
                        context,
                        title: 'Total Providers',
                        value: '${allProviders.length}',
                        icon: Icons.storefront_rounded,
                        color: AppTheme.info,
                      ),
                      _buildMetricCard(
                        context,
                        title: 'Pending Verify',
                        value: '${pending.length}',
                        icon: Icons.hourglass_top_rounded,
                        color: AppTheme.warning,
                      ),
                      _buildMetricCard(
                        context,
                        title: 'Total Bookings',
                        value: '${admin.totalBookingsCount}',
                        icon: Icons.calendar_today_rounded,
                        color: AppTheme.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  // FR-16: Provider Verification Queue
                  Text(
                    'Provider Verification Queue (${pending.length})',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppConstants.spaceSm),

                  if (pending.isEmpty)
                    const AppEmptyState(
                      icon: Icons.verified_user_outlined,
                      title: 'Queue is clear',
                      subtitle: 'All provider verification applications have been reviewed.',
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pending.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
                      itemBuilder: (context, index) {
                        final p = pending[index];
                        return Container(
                          padding: const EdgeInsets.all(AppConstants.spaceMd),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            border: Border.all(color: AppTheme.warning.withAlpha(120)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.warning.withAlpha(20),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.store_rounded, color: AppTheme.warning),
                                  ),
                                  const SizedBox(width: AppConstants.spaceMd),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.shopName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(p.categoryName, style: theme.textTheme.bodySmall),
                                        Text(p.address, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppConstants.spaceMd),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error),
                                      onPressed: () => _showRejectDialog(context, p.id, p.shopName),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                  const SizedBox(width: AppConstants.spaceMd),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                      label: const Text('Approve Provider'),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                                      onPressed: () {
                                        admin.approveProvider(p.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${p.shopName} verified successfully!')),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: AppConstants.spaceLg),

                  // Provider Directory
                  Text(
                    'Registered Service Providers',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppConstants.spaceSm),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allProviders.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
                    itemBuilder: (context, index) {
                      final p = allProviders[index];
                      return Container(
                        padding: const EdgeInsets.all(AppConstants.spaceMd),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.storefront_rounded, color: AppTheme.primary),
                            const SizedBox(width: AppConstants.spaceMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.shopName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${p.categoryName} · ${p.phone}', style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ),
                            _buildStatusBadge(p.verificationStatus),
                          ],
                        ),
                      );
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

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label = status.toUpperCase();

    if (status == 'verified') {
      bg = AppTheme.success.withAlpha(30);
      fg = AppTheme.success;
      label = 'Verified';
    } else if (status == 'pending') {
      bg = AppTheme.warning.withAlpha(30);
      fg = AppTheme.warning;
      label = 'Pending';
    } else {
      bg = AppTheme.error.withAlpha(30);
      fg = AppTheme.error;
      label = 'Rejected';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
