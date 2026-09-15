import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/location_utils.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/domain/entities/user_profile.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final Future<bool> Function(double lat, double lng, String address)? onLocationPicked;

  const MapLocationPickerScreen({super.key, this.onLocationPicked});

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _centerPosition = const LatLng(16.8, 96.1); // Default to Yangon
  bool _isLoadingLocation = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final granted = await LocationUtils.checkAndRequestPermissionWithFeedback(context);
      if (granted) {
        final position = await LocationUtils.getCurrentLocation();
        if (position != null) {
          setState(() {
            _centerPosition = LatLng(position.latitude, position.longitude);
          });
          _mapController.move(_centerPosition, 15.0);
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _onConfirmLocation() async {
    setState(() => _isSaving = true);
    try {
      String address = 'Selected Location';
      try {
        List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
          _centerPosition.latitude,
          _centerPosition.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = [place.street, place.subLocality, place.locality, place.country]
              .whereType<String>()
              .where((p) => p.trim().isNotEmpty)
              .toList();
          if (parts.isNotEmpty) {
            address = parts.join(', ');
          }
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
      }

      if (!mounted) return;
      setState(() => _isSaving = false);
      
      if (widget.onLocationPicked != null) {
        final success = await widget.onLocationPicked!(
          _centerPosition.latitude,
          _centerPosition.longitude,
          address,
        );
        if (mounted) {
          if (success) {
            Navigator.pop(context);
          }
        }
        return;
      }

      final label = await _showLabelDialog(address);
      if (label != null && label.trim().isNotEmpty && mounted) {
        final profile = context.read<ProfileProvider>();
        final newLocation = SavedLocation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          label: label.trim(),
          address: address,
          latitude: _centerPosition.latitude,
          longitude: _centerPosition.longitude,
        );
        final success = await profile.addSavedLocation(newLocation);
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location saved successfully')),
            );
            Navigator.pop(context, newLocation);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save location. ${profile.error ?? ""}')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving location: $e')),
        );
      }
    }
  }

  Future<String?> _showLabelDialog(String address) async {
    final labelCtrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: $address', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: AppConstants.spaceLg),
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(
                labelText: 'Label (e.g. Home, Work)',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, labelCtrl.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pin Your Location'),
        actions: [
          if (!_isLoadingLocation)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _fetchCurrentLocation,
              tooltip: 'Current Location',
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centerPosition,
              initialZoom: 15.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _centerPosition = position.center;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.booking_system',
              ),
            ],
          ),
          // Center Pin Marker
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0), // Adjust to point exactly at center
              child: Icon(
                Icons.location_on,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
          ),
          if (_isLoadingLocation)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          // Confirm Button
          Positioned(
            left: AppConstants.spaceLg,
            right: AppConstants.spaceLg,
            bottom: AppConstants.spaceLg + MediaQuery.of(context).padding.bottom,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _onConfirmLocation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
              ),
              child: _isSaving 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Confirm Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
