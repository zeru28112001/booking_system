import 'package:flutter/foundation.dart';
import '../data/models/notification_model.dart';
import '../data/services/notification_api_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({required NotificationApiService apiService})
      : _apiService = apiService;

  final NotificationApiService _apiService;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _apiService.fetchNotifications();
      _notifications = res.notifications;
      _unreadCount = res.unreadCount;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();

      try {
        await _apiService.markAsRead(notificationId);
      } catch (_) {}
    }
  }

  Future<void> markAllAsRead() async {
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();

    try {
      await _apiService.markAllAsRead();
    } catch (_) {}
  }
}
