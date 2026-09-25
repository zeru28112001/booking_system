import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_language_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/notification_bell_icon_button.dart';
import '../providers/provider_portal_provider.dart';
import '../widgets/provider_booking_details_sheet.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<ProviderPortalProvider>();
      if (provider.profile == null && !provider.isLoading) {
        provider.fetchAllData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langProvider = context.watch<AppLanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(langProvider.translate('provider_dashboard_title')),
        actions: [
          const NotificationBellIconButton(),
          Consumer<ProviderPortalProvider>(
            builder: (context, provider, _) {
              final isAvailable = provider.isAvailable;
              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.spaceMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isAvailable ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                    border: Border.all(
                      color: (isAvailable ? AppTheme.success : AppTheme.warning).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAvailable ? AppTheme.success : AppTheme.warning,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAvailable ? langProvider.translate('active_status') : langProvider.translate('status_busy'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isAvailable ? AppTheme.success : AppTheme.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProviderPortalProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.profile == null) {
            return const AppLoadingIndicator();
          }

          if (provider.error != null && provider.profile == null) {
            return AppErrorState(
              message: provider.error!,
              onRetry: () => provider.fetchAllData(),
            );
          }

          final profile = provider.profile;
          final pending = provider.pendingBookings;

          return RefreshIndicator(
            onRefresh: () => provider.fetchAllData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FR-16: Verification Status Banner
                  _buildVerificationBanner(context, profile?.verificationStatus ?? 'verified'),
                  const SizedBox(height: AppConstants.spaceMd),

                  // Shop Header Info
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spaceMd),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary,
                                AppTheme.primary.withAlpha(180),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          ),
                          child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: AppConstants.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile?.shopName ?? 'Glow Beauty Studio',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile?.categoryName ?? 'Beauty & Salon',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 16, color: AppTheme.warning),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${profile?.rating ?? 4.9} (${profile?.reviewCount ?? 28} ${langProvider.translate("reviews")})',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  // FR-23: Earnings & Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          title: langProvider.translate('total_revenue'),
                          value: AppFormatters.currency(provider.totalRevenue),
                          icon: Icons.account_balance_wallet_outlined,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceMd),
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          title: langProvider.translate('tab_completed'),
                          value: '${provider.completedCount} ${langProvider.translate("nav_bookings")}',
                          icon: Icons.check_circle_outline_rounded,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  // FR-21: Incoming Booking Requests
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${langProvider.translate("pending_approvals")} (${pending.length})',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (pending.isNotEmpty)
                        Text(
                          langProvider.translate('tap_to_manage'),
                          style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceSm),

                  if (pending.isEmpty)
                    AppEmptyState(
                      icon: Icons.done_all_rounded,
                      title: langProvider.translate('no_pending_requests'),
                      subtitle: langProvider.translate('all_pending_processed'),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pending.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
                      itemBuilder: (context, index) {
                        final booking = pending[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            side: const BorderSide(color: AppTheme.divider),
                          ),
                          color: AppTheme.surface,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => ProviderBookingDetailsSheet.show(context, booking),
                            child: Padding(
                              padding: const EdgeInsets.all(AppConstants.spaceMd),
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    booking.serviceName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    AppFormatters.currency(booking.price),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${booking.date} at ${booking.timeSlot}',
                                    style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                                  ),
                                  if (booking.bookingType == 'home_service' && booking.latitude != null && booking.longitude != null) ...[
                                    const SizedBox(width: 12),
                                    const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        booking.address,
                                        style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: AppConstants.spaceMd),
                              GestureDetector(
                                onTap: () {}, // Prevent parent InkWell tap
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.error),
                                        label: Text(langProvider.translate('reject'), style: const TextStyle(color: AppTheme.error)),
                                        onPressed: () async {
                                          final success = await provider.updateBookingStatus(booking.id, 'cancelled');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(success ? 'Booking rejected' : 'Failed to reject booking'),
                                                backgroundColor: success ? AppTheme.error : null,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: AppConstants.spaceMd),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.check_rounded, size: 18),
                                        label: Text(langProvider.translate('accept')),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.success,
                                        ),
                                        onPressed: () async {
                                          final success = await provider.updateBookingStatus(booking.id, 'accepted');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(success ? 'Booking accepted!' : 'Failed to accept booking'),
                                                backgroundColor: success ? AppTheme.success : null,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ],
                            ),
                          ),
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

  Widget _buildVerificationBanner(BuildContext context, String status) {
    if (status == 'verified') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceSm),
        decoration: BoxDecoration(
          color: AppTheme.success.withAlpha(25),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppTheme.success.withAlpha(80)),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified_rounded, color: AppTheme.success, size: 20),
            SizedBox(width: AppConstants.spaceSm),
            Text('Verified Provider Account', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.warning.withAlpha(25),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppTheme.warning.withAlpha(80)),
      ),
      child: const Row(
        children: [
          Icon(Icons.hourglass_top_rounded, color: AppTheme.warning, size: 22),
          SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              'Account Verification Pending Admin Review',
              style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppConstants.spaceSm),
          Text(title, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
