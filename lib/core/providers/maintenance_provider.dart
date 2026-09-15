import 'package:flutter/material.dart';
import '../network/socket_service.dart';

/// Listens to the real-time `maintenance_mode_changed` socket event
/// and exposes [isMaintenanceMode] for the app to react to immediately.
class MaintenanceProvider extends ChangeNotifier {
  MaintenanceProvider() {
    SocketService().onMaintenanceModeChanged(_onMaintenanceChanged);
  }

  bool _isMaintenanceMode = false;

  bool get isMaintenanceMode => _isMaintenanceMode;

  void _onMaintenanceChanged(bool isOn) {
    if (_isMaintenanceMode == isOn) return;
    _isMaintenanceMode = isOn;
    notifyListeners();
  }

  /// Called from SplashScreen after fetching public settings
  void setInitial(bool isOn) {
    _isMaintenanceMode = isOn;
    // No notify needed — splash handles routing
  }

  @override
  void dispose() {
    SocketService().removeMaintenanceModeListener(_onMaintenanceChanged);
    super.dispose();
  }
}
