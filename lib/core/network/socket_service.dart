import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  factory SocketService() => _instance;
  SocketService._internal();
  static final SocketService _instance = SocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;
  final Set<String> _activeRooms = {};

  final List<void Function(dynamic data)> _bookingCreatedListeners = [];
  final List<void Function(dynamic data)> _bookingUpdatedListeners = [];
  final List<void Function(dynamic data)> _providerUpdatedListeners = [];
  final List<void Function(bool isMaintenanceMode)> _maintenanceListeners = [];

  bool get isConnected => _isConnected;

  void init(String serverUrl) {
    if (_socket != null && _socket!.connected) return;

    // Dynamically extract origin URL (scheme + host + port) regardless of /api/v1, /api/v2, etc.
    final parsedUri = Uri.parse(serverUrl);
    final url = parsedUri.hasAuthority ? parsedUri.origin : serverUrl.replaceAll(RegExp(r'/api/v\d+.*'), '');
    debugPrint('🔌 [SocketService] Connecting to WebSocket server: $url');

    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(100)
          .setReconnectionDelay(1000)
          .setTimeout(10000)
          .build(),
    );
    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('⚡️ [SocketService] Socket Connected successfully: ${_socket!.id}');
      for (final room in _activeRooms) {
        debugPrint('📡 [SocketService] Re-joining room on connect: $room');
        _socket!.emit('join_room', room);
      }
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('❌ [SocketService] Socket Disconnected');
    });

    _socket!.onError((err) {
      debugPrint('⚠️ [SocketService] Socket Error: $err');
    });

    _socket!.on('booking_created', (data) {
      debugPrint('⚡️ [SocketService] booking_created event received');
      _notifyCreated(data);
    });

    _socket!.on('global_booking_created', (data) {
      debugPrint('⚡️ [SocketService] global_booking_created event received');
      _notifyCreated(data);
    });

    _socket!.on('booking_updated', (data) {
      debugPrint('⚡️ [SocketService] booking_updated event received');
      _notifyUpdated(data);
    });

    _socket!.on('global_booking_updated', (data) {
      debugPrint('⚡️ [SocketService] global_booking_updated event received');
      _notifyUpdated(data);
    });

    _socket!.on('provider_updated', (data) {
      debugPrint('⚡️ [SocketService] provider_updated event received');
      _notifyProviderUpdated(data);
    });

    _socket!.on('global_provider_updated', (data) {
      debugPrint('⚡️ [SocketService] global_provider_updated event received');
      _notifyProviderUpdated(data);
    });

    _socket!.on('maintenance_mode_changed', (data) {
      final isOn = (data is Map && data['isMaintenanceMode'] == true);
      debugPrint('🔧 [SocketService] maintenance_mode_changed: $isOn');
      for (final cb in List<void Function(bool)>.from(_maintenanceListeners)) {
        try { cb(isOn); } catch (_) {}
      }
    });
  }

  void _notifyCreated(dynamic data) {
    for (final callback in List<void Function(dynamic)>.from(_bookingCreatedListeners)) {
      try {
        callback(data);
      } catch (e) {
        debugPrint('⚠️ [SocketService] Error in booking_created callback: $e');
      }
    }
  }

  void _notifyUpdated(dynamic data) {
    for (final callback in List<void Function(dynamic)>.from(_bookingUpdatedListeners)) {
      try {
        callback(data);
      } catch (e) {
        debugPrint('⚠️ [SocketService] Error in booking_updated callback: $e');
      }
    }
  }

  void _notifyProviderUpdated(dynamic data) {
    for (final callback in List<void Function(dynamic)>.from(_providerUpdatedListeners)) {
      try {
        callback(data);
      } catch (e) {
        debugPrint('⚠️ [SocketService] Error in provider_updated callback: $e');
      }
    }
  }

  void joinRoom(String roomName) {
    if (roomName.isEmpty) return;
    _activeRooms.add(roomName);
    if (_socket != null && _socket!.connected) {
      debugPrint('📡 [SocketService] Joining room: $roomName');
      _socket!.emit('join_room', roomName);
    } else {
      debugPrint('📡 [SocketService] Queued room for connect: $roomName');
    }
  }

  void leaveRoom(String roomName) {
    _activeRooms.remove(roomName);
    if (_socket != null) {
      debugPrint('👋 [SocketService] Leaving room: $roomName');
      _socket!.emit('leave_room', roomName);
    }
  }

  void onBookingCreated(void Function(dynamic data) callback) {
    if (!_bookingCreatedListeners.contains(callback)) {
      _bookingCreatedListeners.add(callback);
    }
  }

  void onBookingUpdated(void Function(dynamic data) callback) {
    if (!_bookingUpdatedListeners.contains(callback)) {
      _bookingUpdatedListeners.add(callback);
    }
  }

  void onProviderUpdated(void Function(dynamic data) callback) {
    if (!_providerUpdatedListeners.contains(callback)) {
      _providerUpdatedListeners.add(callback);
    }
  }

  void removeBookingCreatedListener(void Function(dynamic data) callback) {
    _bookingCreatedListeners.remove(callback);
  }

  void removeBookingUpdatedListener(void Function(dynamic data) callback) {
    _bookingUpdatedListeners.remove(callback);
  }

  void removeProviderUpdatedListener(void Function(dynamic data) callback) {
    _providerUpdatedListeners.remove(callback);
  }

  void onMaintenanceModeChanged(void Function(bool isMaintenanceMode) callback) {
    if (!_maintenanceListeners.contains(callback)) {
      _maintenanceListeners.add(callback);
    }
  }

  void removeMaintenanceModeListener(void Function(bool isMaintenanceMode) callback) {
    _maintenanceListeners.remove(callback);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    _activeRooms.clear();
    _bookingCreatedListeners.clear();
    _bookingUpdatedListeners.clear();
    _providerUpdatedListeners.clear();
    _maintenanceListeners.clear();
  }
}
