import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../providers/provider_portal_provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Provider Dashboard'),
        actions: [
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
                        isAvailable ? 'Available' : 'Busy',
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
                                    '${profile?.rating ?? 4.9} (${profile?.reviewCount ?? 28} reviews)',
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
                          title: 'Total Revenue',
                          value: AppFormatters.currency(provider.totalRevenue),
                          icon: Icons.account_balance_wallet_outlined,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceMd),
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          title: 'Completed',
                          value: '${provider.completedCount} Bookings',
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
                        'Pending Requests (${pending.length})',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (pending.isNotEmpty)
                        Text(
                          'Tap to manage',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceSm),

                  if (pending.isEmpty)
                    const AppEmptyState(
                      icon: Icons.done_all_rounded,
                      title: 'No pending requests',
                      subtitle: 'All customer booking requests have been processed.',
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pending.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
                      itemBuilder: (context, index) {
                        final booking = pending[index];
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
                              ),
                              const SizedBox(height: AppConstants.spaceMd),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.error),
                                      label: const Text('Reject', style: TextStyle(color: AppTheme.error)),
                                      onPressed: () {
                                        provider.updateBookingStatus(booking.id, 'cancelled');
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: AppConstants.spaceMd),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.check_rounded, size: 18),
                                      label: const Text('Accept'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.success,
                                      ),
                                      onPressed: () {
                                        provider.updateBookingStatus(booking.id, 'accepted');
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
