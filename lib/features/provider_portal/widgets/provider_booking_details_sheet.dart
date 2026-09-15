import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import 'package:booking_system/features/booking/domain/entities/booking.dart';
import '../providers/provider_portal_provider.dart';
import '../screens/booking_location_map_screen.dart';

class ProviderBookingDetailsSheet extends StatelessWidget {
  const ProviderBookingDetailsSheet({super.key, required this.booking});

  final Booking booking;

  static void show(BuildContext context, Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
      ),
      builder: (ctx) => ProviderBookingDetailsSheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Booking Details', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppConstants.spaceSm),

              if (booking.latitude != null && booking.longitude != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customer Location Map',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingLocationMapScreen(booking: booking),
                          ),
                        );
                      },
                      icon: const Icon(Icons.fullscreen_rounded, size: 18),
                      label: const Text('Fullscreen Map'),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceSm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.divider),
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(booking.latitude!, booking.longitude!),
                            initialZoom: 15.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.booking_system',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(booking.latitude!, booking.longitude!),
                                  width: 44,
                                  height: 44,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.error.withAlpha(40),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: AppTheme.error,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          left: 8,
                          bottom: 8,
                          right: 8,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookingLocationMapScreen(booking: booking),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface.withAlpha(240),
                                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(25),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.pin_drop_rounded, size: 18, color: AppTheme.error),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        booking.address,
                                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.open_in_full_rounded, size: 16, color: AppTheme.primary),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),
              ],
              _buildDetailRow(context, 'Service', booking.serviceName),
              if (booking.staffName != null && booking.staffName!.isNotEmpty)
                _buildDetailRow(context, 'Staff', booking.staffName!),
              _buildDetailRow(
                context,
                'Service Mode',
                booking.bookingType == 'home_service' ? 'Home Service (On-Site)' : 'At Shop',
              ),
              _buildDetailRow(context, 'Status', booking.status.toUpperCase()),
              _buildDetailRow(context, 'Date & Time', '${booking.date} at ${booking.timeSlot}'),
              _buildDetailRow(context, 'Price', AppFormatters.currency(booking.price)),
              if (booking.durationMinutes > 0)
                _buildDetailRow(context, 'Duration', '${booking.durationMinutes} minutes'),
              _buildDetailRow(context, 'Customer Name', booking.customerName ?? 'Customer'),
              
              if (booking.customerPhone != null && booking.customerPhone!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text('Customer Phone', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                      ),
                      Expanded(
                        child: Text(
                          booking.customerPhone!,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.phone_in_talk_rounded, size: 18, color: AppTheme.primary),
                    ],
                  ),
                ),

              if (booking.bookingType == 'home_service' && booking.latitude != null && booking.longitude != null)
                _buildDetailRow(
                  context,
                  'Customer Address',
                  booking.address,
                ),
              _buildDetailRow(context, 'Payment Method', booking.paymentMethod),
              
              if (booking.notes.trim().isNotEmpty) ...[
                const SizedBox(height: AppConstants.spaceSm),
                Text('Customer Notes:', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Text(booking.notes, style: theme.textTheme.bodyMedium),
                ),
              ],
              const SizedBox(height: AppConstants.spaceLg),
              const Divider(),
              const SizedBox(height: AppConstants.spaceSm),

              // Status Action Buttons
              Consumer<ProviderPortalProvider>(
                builder: (context, provider, _) {
                  final status = booking.status;
                  if (status == 'pending') {
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.error),
                            label: const Text('Reject Booking', style: TextStyle(color: AppTheme.error)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.error),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () async {
                              final success = await provider.updateBookingStatus(booking.id, 'cancelled');
                              if (context.mounted) {
                                Navigator.pop(context);
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
                            label: const Text('Accept Booking'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.success,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () async {
                              final success = await provider.updateBookingStatus(booking.id, 'accepted');
                              if (context.mounted) {
                                Navigator.pop(context);
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
                    );
                  } else if (status == 'accepted') {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: const Text('Mark as In Progress'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          await provider.updateBookingStatus(booking.id, 'in_progress');
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Booking marked in progress')),
                            );
                          }
                        },
                      ),
                    );
                  } else if (status == 'in_progress') {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: const Text('Mark as Completed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          await provider.updateBookingStatus(booking.id, 'completed');
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Booking marked as completed!')),
                            );
                          }
                        },
                      ),
                    );
                  }
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Text(
                      'Booking Status: ${status.toUpperCase()}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: status == 'cancelled' ? AppTheme.error : AppTheme.success,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppConstants.spaceXl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

