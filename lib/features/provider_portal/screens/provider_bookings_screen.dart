import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import 'package:booking_system/features/booking/domain/entities/booking.dart';
import '../providers/provider_portal_provider.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = ['All', 'Pending', 'Accepted', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Provider Bookings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Consumer<ProviderPortalProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.bookings.isEmpty) {
            return const AppLoadingIndicator();
          }

          final all = provider.bookings;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList(context, provider, all),
              _buildBookingList(context, provider, all.where((b) => b.status == 'pending').toList()),
              _buildBookingList(context, provider, all.where((b) => b.status == 'accepted').toList()),
              _buildBookingList(context, provider, all.where((b) => b.status == 'in_progress').toList()),
              _buildBookingList(context, provider, all.where((b) => b.status == 'completed').toList()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    ProviderPortalProvider provider,
    List<Booking> list,
  ) {
    if (list.isEmpty) {
      return const AppEmptyState(
        icon: Icons.event_busy_rounded,
        title: 'No bookings found',
        subtitle: 'There are no bookings matching this status.',
      );
    }

    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      itemCount: list.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
      itemBuilder: (context, index) {
        final booking = list[index];
        final status = booking.status;

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
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  _buildStatusBadge(status),
                ],
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text('${booking.date} at ${booking.timeSlot}', style: theme.textTheme.bodySmall),
                  const SizedBox(width: 12),
                  const Icon(Icons.payments_outlined, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(AppFormatters.currency(booking.price), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(booking.address, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceMd),

              // FR-22: Stepper Status Actions
              if (status == 'pending') ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => provider.updateBookingStatus(booking.id, 'cancelled'),
                        child: const Text('Reject', style: TextStyle(color: AppTheme.error)),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                        onPressed: () => provider.updateBookingStatus(booking.id, 'accepted'),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ] else if (status == 'accepted') ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Mark as In Progress'),
                  onPressed: () => provider.updateBookingStatus(booking.id, 'in_progress'),
                ),
              ] else if (status == 'in_progress') ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('Mark as Completed'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                  onPressed: () => provider.updateBookingStatus(booking.id, 'completed'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label = status.toUpperCase();

    switch (status) {
      case 'pending':
        bg = AppTheme.warning.withAlpha(30);
        fg = AppTheme.warning;
        label = 'Pending';
        break;
      case 'accepted':
        bg = AppTheme.info.withAlpha(30);
        fg = AppTheme.info;
        label = 'Accepted';
        break;
      case 'in_progress':
        bg = AppTheme.primary.withAlpha(30);
        fg = AppTheme.primary;
        label = 'In Progress';
        break;
      case 'completed':
        bg = AppTheme.success.withAlpha(30);
        fg = AppTheme.success;
        label = 'Completed';
        break;
      case 'cancelled':
        bg = AppTheme.error.withAlpha(30);
        fg = AppTheme.error;
        label = 'Cancelled';
        break;
      default:
        bg = Colors.grey.withAlpha(30);
        fg = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
