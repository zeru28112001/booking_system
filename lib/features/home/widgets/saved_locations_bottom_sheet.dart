import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/location_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../screens/map_location_picker_screen.dart';

class SavedLocationsBottomSheet extends StatefulWidget {
  const SavedLocationsBottomSheet({super.key});

  @override
  State<SavedLocationsBottomSheet> createState() => _SavedLocationsBottomSheetState();
}

class _SavedLocationsBottomSheetState extends State<SavedLocationsBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.profile == null) {
        profileProvider.fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final locationProvider = context.watch<LocationProvider>();
    final savedLocations = profileProvider.profile?.savedLocations ?? [];
    
    final activeLat = locationProvider.activeLat ?? 16.8;
    final activeLng = locationProvider.activeLng ?? 96.1;
    final activeName = locationProvider.currentLocationName ?? 'Current Location';
    final activePos = LatLng(activeLat, activeLng);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            const SizedBox(height: AppConstants.spaceSm),
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
            const SizedBox(height: AppConstants.spaceMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Location Map',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openMapPicker(context),
                    icon: const Icon(Icons.edit_location_alt_rounded, size: 18),
                    label: const Text('Adjust Pin'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),

            // Map Preview Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                child: Container(
                  height: 170,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.divider),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  ),
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: activePos,
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
                                point: activePos,
                                width: 40,
                                height: 40,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withAlpha(40),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: AppTheme.primary,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Location Badge Overlay
                      Positioned(
                        left: 12,
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withAlpha(235),
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.my_location_rounded, size: 16, color: AppTheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  activeName,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spaceLg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Saved Addresses',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),

            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                children: [
                  if (savedLocations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppConstants.spaceLg),
                      child: Center(
                        child: Text(
                          'No saved locations yet.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  ...savedLocations.map((loc) {
                    final isSelected = locationProvider.selectedSavedLocation?.id == loc.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary.withAlpha(15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        border: isSelected ? Border.all(color: AppTheme.primary.withAlpha(60)) : null,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? AppTheme.primary : Colors.grey.shade300,
                          child: Icon(
                            isSelected ? Icons.check_rounded : Icons.bookmark_outline,
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                        title: Text(
                          loc.label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppTheme.primary : null,
                          ),
                        ),
                        subtitle: Text(
                          loc.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          context.read<LocationProvider>().setSavedLocation(loc);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: AppConstants.spaceMd),
                  OutlinedButton.icon(
                    onPressed: () => _openMapPicker(context),
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text('Add New Location'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _openMapPicker(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapLocationPickerScreen(),
      ),
    );
  }
}

