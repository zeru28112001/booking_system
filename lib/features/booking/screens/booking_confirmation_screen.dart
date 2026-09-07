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

/// Phase 4 — success screen shown right after a booking is created.
class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    // Deferring keeps notifyListeners out of the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BookingProvider>().fetchBookingById(widget.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(centerTitle: false, title: const Text('Confirmation')),
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
              subtitle: 'We could not load the booking you just made.',
              actionLabel: 'Back to home',
              onAction: () => context.go('/home'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            child: Column(
              children: [
                const SizedBox(height: AppConstants.spaceMd),
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 44,
                    color: AppTheme.onPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                Text('Booking Confirmed!', style: theme.textTheme.headlineLarge),
                const SizedBox(height: AppConstants.spaceSm),
                Text(
                  'Your request is with ${current.providerName}. '
                  'They will confirm your ${current.serviceName} appointment soon.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                BookingSummaryCard(booking: current),
                const SizedBox(height: AppConstants.spaceLg),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<BookingProvider>(
        builder: (context, booking, _) {
          if (booking.booking == null) return const SizedBox.shrink();
          return SafeArea(
            child: Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    label: 'View Booking',
                    icon: Icons.event_note_outlined,
                    onPressed: () =>
                        context.pushReplacement('/booking/${widget.bookingId}'),
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  AppOutlinedButton(
                    label: 'Back to Home',
                    onPressed: () => context.go('/home'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
