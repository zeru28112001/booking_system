import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:booking_system/features/booking/domain/entities/booking.dart';

class BookingLocationMapScreen extends StatefulWidget {
  const BookingLocationMapScreen({super.key, required this.booking});

  final Booking booking;

  @override
  State<BookingLocationMapScreen> createState() => _BookingLocationMapScreenState();
}

class _BookingLocationMapScreenState extends State<BookingLocationMapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lat = widget.booking.latitude ?? 16.8000;
    final lng = widget.booking.longitude ?? 96.1000;
    final pos = LatLng(lat, lng);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.booking.customerName != null && widget.booking.customerName!.isNotEmpty
            ? '${widget.booking.customerName}\'s Location'
            : 'Customer Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            tooltip: 'Re-center Pin',
            onPressed: () {
              _mapController.move(pos, 16.0);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: pos,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.booking_system',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: pos,
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.error.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.location_on,
                        color: AppTheme.error,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Bottom Info Sheet Overlay
          Positioned(
            left: AppConstants.spaceMd,
            right: AppConstants.spaceMd,
            bottom: AppConstants.spaceLg,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              color: AppTheme.surface.withAlpha(245),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pin_drop_rounded, color: AppTheme.error, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.booking.address,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          widget.booking.customerName ?? 'Customer',
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (widget.booking.customerPhone != null && widget.booking.customerPhone!.isNotEmpty) ...[
                          const SizedBox(width: 16),
                          const Icon(Icons.phone_outlined, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            widget.booking.customerPhone!,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Coordinates: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
