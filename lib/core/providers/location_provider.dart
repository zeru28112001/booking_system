import 'package:flutter/foundation.dart';
import '../utils/location_utils.dart';
import '../../features/profile/domain/entities/user_profile.dart';

class LocationProvider extends ChangeNotifier {
  String? _currentLocationName;
  double? _activeLat;
  double? _activeLng;
  SavedLocation? _selectedSavedLocation;

  String? get currentLocationName => _currentLocationName;
  double? get activeLat => _activeLat;
  double? get activeLng => _activeLng;
  SavedLocation? get selectedSavedLocation => _selectedSavedLocation;

  /// Fetches the real GPS position and sets it as the active location if no saved location is currently selected.
  Future<void> fetchGpsLocation() async {
    final position = await LocationUtils.getCurrentLocation();
    if (position != null) {
      if (_selectedSavedLocation == null) {
        _activeLat = position.latitude;
        _activeLng = position.longitude;
      }
      final name = await LocationUtils.getAddressFromCoordinates(position.latitude, position.longitude);
      if (name != null) {
        _currentLocationName = name;
      } else {
        _currentLocationName = 'Current Location';
      }
      notifyListeners();
    }
  }

  /// Sets a specific saved location as the active location.
  void setSavedLocation(SavedLocation location) {
    _selectedSavedLocation = location;
    _activeLat = location.latitude;
    _activeLng = location.longitude;
    _currentLocationName = location.label;
    notifyListeners();
  }

  /// Clears the selected saved location and falls back to GPS if available.
  void clearSavedLocation() {
    _selectedSavedLocation = null;
    fetchGpsLocation(); // Refetch to reset
    notifyListeners();
  }
}
