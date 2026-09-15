import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Data',
            onPressed: () => context.read<AdminPortalProvider>().fetchAdminDashboardData(),
          ),
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
          if (admin.isLoading && admin.providers.isEmpty) {
            return const AppLoadingIndicator();
          }

          final pendingVerifyCount = admin.pendingVerifications.length;
          final pendingRequestCount = admin.pendingProfileRequests.length;

          return RefreshIndicator(
            onRefresh: () => admin.fetchAdminDashboardData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Financial GMV & Top Metrics Grid
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.spaceLg),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withAlpha(50),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.payments_rounded, color: Colors.white70, size: 20),
                            const SizedBox(width: AppConstants.spaceXs),
                            Text(
                              'Total Gross Revenue (GMV)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spaceXs),
                        Text(
                          AppFormatters.currency(admin.totalRevenue.toInt()),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceSm),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  // System Metrics Grid
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
                        value: '${admin.providers.length}',
                        icon: Icons.storefront_rounded,
                        color: AppTheme.info,
                      ),
                      _buildMetricCard(
                        context,
                        title: 'Pending Verifications',
                        value: '$pendingVerifyCount',
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

                  // Quick Action Queue Alerts
                  if (pendingVerifyCount > 0 || pendingRequestCount > 0) ...[
                    Text(
                      'Action Required',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppConstants.spaceSm),
                    if (pendingVerifyCount > 0)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                        padding: const EdgeInsets.all(AppConstants.spaceMd),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withAlpha(20),
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          border: Border.all(color: AppTheme.warning.withAlpha(80)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_outlined, color: AppTheme.warning),
                            const SizedBox(width: AppConstants.spaceMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$pendingVerifyCount Provider Verification Applications',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Review store details & business documents',
                                    style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (pendingRequestCount > 0)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                        padding: const EdgeInsets.all(AppConstants.spaceMd),
                        decoration: BoxDecoration(
                          color: AppTheme.info.withAlpha(20),
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          border: Border.all(color: AppTheme.info.withAlpha(80)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.published_with_changes_rounded, color: AppTheme.info),
                            const SizedBox(width: AppConstants.spaceMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$pendingRequestCount Profile Edit Approval Requests',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Providers requested changes to isShop, isHomeService, or Store Name',
                                    style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppConstants.spaceLg),
                  ],

                  // System Status Overview Card
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spaceMd),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.speed_rounded, color: AppTheme.primary, size: 20),
                            const SizedBox(width: AppConstants.spaceSm),
                            Text('Platform Operational Status', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: AppConstants.spaceLg),
                        _buildStatusRow(
                          label: 'Maintenance Mode',
                          value: admin.systemSettings.isMaintenanceMode ? 'Active (Offline)' : 'Inactive (Live)',
                          isOK: !admin.systemSettings.isMaintenanceMode,
                        ),
                        _buildStatusRow(
                          label: 'Support Contact',
                          value: admin.systemSettings.supportPhone,
                          isOK: true,
                        ),
                      ],
                    ),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({required String label, required String value, required bool isOK}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isOK ? AppTheme.success : AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
