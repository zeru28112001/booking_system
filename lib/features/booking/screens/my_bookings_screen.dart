import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/skeletons/booking_list_skeleton.dart';
import '../../../core/widgets/animations/staggered_entrance.dart';
import '../../../core/widgets/animations/app_scale_button.dart';
import '../domain/entities/booking.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';

import '../../../core/localization/app_language_provider.dart';

/// Phase 4 — the customer's bookings, split into Pending / Upcoming / History.
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BookingProvider>().fetchMyBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<AppLanguageProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(langProvider.translate('my_bookings')),
          bottom: TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            tabs: [
              Tab(text: langProvider.translate('tab_pending')),
              Tab(text: langProvider.translate('tab_confirmed')),
              Tab(text: langProvider.translate('tab_completed')),
            ],
          ),
        ),
        body: Consumer<BookingProvider>(
          builder: (context, booking, _) {
            if (booking.isLoading && booking.bookings.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(AppConstants.spaceMd),
                child: BookingListSkeleton(itemCount: 5),
              );
            }

            if (booking.error != null) {
              return AppErrorState(
                message: booking.error!,
                onRetry: () =>
                    context.read<BookingProvider>().fetchMyBookings(),
              );
            }

            return TabBarView(
              children: [
                _BookingTab(
                  bookings: booking.pendingBookings,
                  emptyIcon: Icons.hourglass_empty_rounded,
                  emptyTitle: 'No pending bookings',
                  emptySubtitle:
                      'Requests waiting for a provider to accept show up here.',
                ),
                _BookingTab(
                  bookings: booking.upcomingBookings,
                  emptyIcon: Icons.event_available_outlined,
                  emptyTitle: 'Nothing upcoming',
                  emptySubtitle:
                      'Book a local pro and your appointments land here.',
                ),
                _BookingTab(
                  bookings: booking.historyBookings,
                  emptyIcon: Icons.history_rounded,
                  emptyTitle: 'No history yet',
                  emptySubtitle:
                      'Completed and cancelled bookings are kept here.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingTab extends StatelessWidget {
  const _BookingTab({
    required this.bookings,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final List<Booking> bookings;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<BookingProvider>().fetchMyBookings(),
      child: bookings.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                alignment: Alignment.center,
                child: AppEmptyState(
                  icon: emptyIcon,
                  title: emptyTitle,
                  subtitle: emptySubtitle,
                ),
              ),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              itemCount: bookings.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppConstants.spaceMd),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return StaggeredEntrance(
                  index: index,
                  child: AppScaleButton(
                    onTap: () async {
                      await context.push('/booking/${booking.id}');
                      if (context.mounted) {
                        context.read<BookingProvider>().fetchMyBookings();
                      }
                    },
                    child: BookingCard(
                      booking: booking,
                      onTap: () async {
                        await context.push('/booking/${booking.id}');
                        if (context.mounted) {
                          context.read<BookingProvider>().fetchMyBookings();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
