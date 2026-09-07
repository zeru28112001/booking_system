import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/status_stepper.dart';

/// Phase 4 — one booking: status track, full summary, cancel while pending.
class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Deferring keeps notifyListeners out of the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BookingProvider>().fetchBookingById(widget.bookingId);
    });
  }

  Future<void> _confirmCancel() async {
    final providerName =
        context.read<BookingProvider>().booking?.providerName ?? 'this provider';

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: Text(
          'Your appointment with $providerName will be cancelled. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Cancel booking',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (shouldCancel != true || !mounted) return;

    final cancelled =
        await context.read<BookingProvider>().cancelBooking(widget.bookingId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cancelled ? 'Booking cancelled.' : 'Could not cancel this booking.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(centerTitle: false, title: const Text('Booking details')),
      body: Consumer<BookingProvider>(
        builder: (context, booking, _) {
          if (booking.isLoading && booking.booking == null) {
            return const AppLoadingIndicator();
          }

          if (booking.error != null && booking.booking == null) {
            return AppErrorState(
              message: booking.error!,
              onRetry: () => context
                  .read<BookingProvider>()
                  .fetchBookingById(widget.bookingId),
            );
          }

          final current = booking.booking;
          if (current == null) {
            return AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Booking not found',
              subtitle: 'This booking may have been removed.',
              actionLabel: 'Go back',
              onAction: () => context.pop(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppConstants.spaceMd),
                StatusStepper(status: current.status),
                const SizedBox(height: AppConstants.spaceLg),
                BookingSummaryCard(booking: current),
                const SizedBox(height: AppConstants.spaceMd),
                Text(
                  'Booking ID: ${current.id}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<BookingProvider>(
        builder: (context, booking, _) {
          final current = booking.booking;
          if (current == null) return const SizedBox.shrink();

          if (current.status == 'pending') {
            return SafeArea(
              child: Container(
                color: AppTheme.surface,
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                child: AppOutlinedButton(
                  label: 'Cancel Booking',
                  icon: Icons.cancel_outlined,
                  onPressed: booking.isSubmitting ? null : _confirmCancel,
                ),
              ),
            );
          }

          if (current.status == 'completed') {
            return SafeArea(
              child: Container(
                color: AppTheme.surface,
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                child: AppButton(
                  label: 'Write a Review',
                  icon: Icons.rate_review_outlined,
                  onPressed: () {
                    context.push('/write-review/${current.providerId}'
                        '?name=${Uri.encodeComponent(current.providerName)}'
                        '&bookingId=${current.id}');
                  },
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
