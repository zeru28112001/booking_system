import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../domain/entities/booking.dart';
import '../domain/entities/payment_method.dart';

/// Label/value breakdown of a booking plus its total and payment method details.
/// Shared by the confirmation screen and the booking detail screen.
class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pmConfig = booking.paymentMethodConfig;
    final paymentName = pmConfig?.name.isNotEmpty == true
        ? pmConfig!.name
        : PaymentMethod.fromValue(booking.paymentMethod).label;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            value: paymentName,
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
          if (pmConfig != null &&
              (pmConfig.accountName.isNotEmpty ||
                  pmConfig.accountNumber.isNotEmpty ||
                  pmConfig.instructions.isNotEmpty ||
                  pmConfig.qrCodeUrl.isNotEmpty)) ...[
            const SizedBox(height: AppConstants.spaceMd),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(12),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(color: AppTheme.primary.withAlpha(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 18, color: AppTheme.primary),
                      const SizedBox(width: AppConstants.spaceXs),
                      Text(
                        'Payment Info',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  if (pmConfig.accountName.isNotEmpty) ...[
                    Text(
                      'Account Name: ${pmConfig.accountName}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (pmConfig.accountNumber.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Account / Phone: ${pmConfig.accountNumber}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          tooltip: 'Copy account number',
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: pmConfig.accountNumber),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Account number copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (pmConfig.instructions.isNotEmpty) ...[
                    Text(
                      'Instructions: ${pmConfig.instructions}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (pmConfig.qrCodeUrl.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spaceSm),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                        child: Image.network(
                          pmConfig.qrCodeUrl,
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
