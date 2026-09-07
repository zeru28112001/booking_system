import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../domain/entities/booking.dart';
import '../domain/entities/payment_method.dart';

/// Label/value breakdown of a booking plus its total.
/// Shared by the confirmation screen and the booking detail screen.
class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Provider', value: booking.providerName),
          _SummaryRow(label: 'Service', value: booking.serviceName),
          if (booking.staffName != null && booking.staffName!.isNotEmpty)
            _SummaryRow(label: 'Staff', value: booking.staffName!),
          _SummaryRow(label: 'Date', value: AppFormatters.dateLabel(booking.date)),
          _SummaryRow(
            label: 'Time',
            value: AppFormatters.timeLabel(booking.timeSlot),
          ),
          _SummaryRow(
            label: 'Duration',
            value: AppFormatters.durationLabel(booking.durationMinutes),
          ),
          _SummaryRow(label: 'Address', value: booking.address),
          if (booking.notes.isNotEmpty)
            _SummaryRow(label: 'Notes', value: booking.notes),
          _SummaryRow(
            label: 'Payment',
            value: PaymentMethod.fromValue(booking.paymentMethod).label,
          ),
          const Divider(height: AppConstants.spaceLg),
          Row(
            children: [
              Text('Total', style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                AppFormatters.currency(booking.price),
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
