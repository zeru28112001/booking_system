class NotificationModel {
  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'booking_status',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
    );
  }

  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      data: data,
    );
  }
}
