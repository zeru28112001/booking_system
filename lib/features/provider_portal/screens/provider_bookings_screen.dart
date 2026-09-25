import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_language_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import 'package:booking_system/features/booking/domain/entities/booking.dart';
import '../providers/provider_portal_provider.dart';
import '../widgets/provider_booking_details_sheet.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabKeys = [
    'tab_all',
    'tab_pending',
    'tab_accepted',
    'tab_in_progress',
    'tab_completed',
    'tab_cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabKeys.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<AppLanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(langProvider.translate('provider_bookings_title')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabKeys.map((k) => Tab(text: langProvider.translate(k))).toList(),
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
              _buildBookingList(context, provider, all, langProvider),
              _buildBookingList(context, provider, all.where((b) => b.status == 'pending').toList(), langProvider),
              _buildBookingList(context, provider, all.where((b) => b.status == 'accepted').toList(), langProvider),
              _buildBookingList(context, provider, all.where((b) => b.status == 'in_progress').toList(), langProvider),
              _buildBookingList(context, provider, all.where((b) => b.status == 'completed').toList(), langProvider),
              _buildBookingList(context, provider, all.where((b) => b.status == 'cancelled').toList(), langProvider),
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
    AppLanguageProvider langProvider,
  ) {
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.fetchAllData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: AppEmptyState(
              icon: Icons.event_busy_rounded,
              title: langProvider.translate('no_bookings_found'),
              subtitle: 'There are no bookings matching this status.',
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => provider.fetchAllData(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        itemCount: list.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
        itemBuilder: (context, index) {
        final booking = list[index];
        final status = booking.status;

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
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  _buildStatusBadge(status, langProvider),
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
                  const Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(booking.customerName ?? 'Customer', style: theme.textTheme.bodySmall),
                  if (booking.customerPhone != null && booking.customerPhone!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.phone_outlined, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(booking.customerPhone!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
              if (booking.bookingType == 'home_service' && booking.latitude != null && booking.longitude != null) ...[
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
              ],
              const SizedBox(height: AppConstants.spaceMd),

              // FR-22: Stepper Status Actions
              if (status == 'pending') ...[
                GestureDetector(
                  onTap: () {}, // Isolate tap from parent InkWell
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.updateBookingStatus(booking.id, 'cancelled'),
                          child: Text(langProvider.translate('reject'), style: const TextStyle(color: AppTheme.error)),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceMd),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                          onPressed: () => provider.updateBookingStatus(booking.id, 'accepted'),
                          child: Text(langProvider.translate('accept')),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (status == 'accepted') ...[
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.updateBookingStatus(booking.id, 'no_show'),
                          child: Text(langProvider.translate('tab_no_show'), style: const TextStyle(color: AppTheme.error)),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceSm),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          label: Text(langProvider.translate('tab_in_progress')),
                          onPressed: () => provider.updateBookingStatus(booking.id, 'in_progress'),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (status == 'in_progress') ...[
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.updateBookingStatus(booking.id, 'no_show'),
                          child: Text(langProvider.translate('tab_no_show'), style: const TextStyle(color: AppTheme.error)),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceSm),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                          label: Text(langProvider.translate('tab_completed')),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                          onPressed: () => provider.updateBookingStatus(booking.id, 'completed'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              ],
            ),
          ),
        ),
      );
    },
    ),
  );
}

  Widget _buildStatusBadge(String status, AppLanguageProvider langProvider) {
    Color bg;
    Color fg;
    String label = status.toUpperCase();

    switch (status) {
      case 'pending':
        bg = AppTheme.warning.withAlpha(30);
        fg = AppTheme.warning;
        label = langProvider.translate('tab_pending');
        break;
      case 'accepted':
        bg = AppTheme.info.withAlpha(30);
        fg = AppTheme.info;
        label = langProvider.translate('tab_accepted');
        break;
      case 'in_progress':
        bg = AppTheme.primary.withAlpha(30);
        fg = AppTheme.primary;
        label = langProvider.translate('tab_in_progress');
        break;
      case 'completed':
        bg = AppTheme.success.withAlpha(30);
        fg = AppTheme.success;
        label = langProvider.translate('tab_completed');
        break;
      case 'no_show':
        bg = Colors.purple.withAlpha(30);
        fg = Colors.purple;
        label = langProvider.translate('tab_no_show');
        break;
      case 'cancelled':
        bg = AppTheme.error.withAlpha(30);
        fg = AppTheme.error;
        label = langProvider.translate('tab_cancelled');
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
