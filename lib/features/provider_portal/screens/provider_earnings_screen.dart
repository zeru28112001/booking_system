import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_empty_state.dart';
import 'package:booking_system/features/booking/domain/entities/booking.dart';
import '../providers/provider_portal_provider.dart';

class ProviderEarningsScreen extends StatelessWidget {
  const ProviderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProviderPortalProvider>();
    final bookings = provider.bookings;
    final List<Booking> revenueList = bookings
        .where((b) => b.status == 'completed' || b.status == 'accepted' || b.status == 'in_progress')
        .toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Earnings & Payments'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue overview banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF4338CA)],
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Revenue',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.currency(provider.totalRevenue),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Row(
                    children: [
                      _buildHeaderStat('Completed', '${provider.completedCount}'),
                      const SizedBox(width: AppConstants.spaceLg),
                      _buildHeaderStat('Active', '${provider.activeBookings.length}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),

            Text(
              'Payment History',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.spaceSm),

            if (revenueList.isEmpty)
              const AppEmptyState(
                icon: Icons.history_rounded,
                title: 'No earnings recorded yet',
                subtitle: 'Completed and active booking earnings will show up here.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: revenueList.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
                itemBuilder: (context, index) {
                  final b = revenueList[index];
                  final isCompleted = b.status == 'completed';
                  final badgeColor = isCompleted
                      ? AppTheme.success
                      : (b.status == 'accepted' ? AppTheme.primary : AppTheme.warning);

                  return Container(
                    padding: const EdgeInsets.all(AppConstants.spaceMd),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: badgeColor.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCompleted ? Icons.check_circle_outline_rounded : Icons.arrow_downward_rounded,
                            color: badgeColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(b.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withAlpha(25),
                                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                                    ),
                                    child: Text(
                                      b.status.toUpperCase(),
                                      style: TextStyle(
                                        color: badgeColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${b.date} · ${b.timeSlot} · ${b.paymentMethod.toUpperCase()}',
                                style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+${AppFormatters.currency(b.price)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
