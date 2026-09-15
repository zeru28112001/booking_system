import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationApiService {
  const NotificationApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// GET /notifications?page=1&limit=20
  Future<({List<NotificationModel> notifications, int unreadCount})> fetchNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final responseData = await _apiClient.get(
      '/notifications?page=$page&limit=$limit',
    ) as Map<String, dynamic>;

    final data = (responseData['data'] as Map<String, dynamic>?) ?? responseData;
    final list = (data['notifications'] as List<dynamic>?) ?? [];
    final unreadCount = (data['unreadCount'] as int?) ?? 0;

    final notifications = list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return (notifications: notifications, unreadCount: unreadCount);
  }

  /// PATCH /notifications/:id/read
  Future<void> markAsRead(String notificationId) async {
    await _apiClient.patch('/notifications/$notificationId/read');
  }

  /// PATCH /notifications/read-all
  Future<void> markAllAsRead() async {
    await _apiClient.patch('/notifications/read-all');
  }
}
