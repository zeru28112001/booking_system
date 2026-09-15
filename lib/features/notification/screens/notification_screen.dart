import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../data/models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'booking_created':
        return Icons.add_task_rounded;
      case 'booking_status':
      case 'booking_auto_completed':
        return Icons.check_circle_outline_rounded;
      case 'booking_cancelled':
      case 'booking_auto_cancelled':
        return Icons.cancel_outlined;
      case 'payment':
        return Icons.payments_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      case 'review':
        return Icons.star_rate_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'booking_created':
        return const Color(0xFF2563EB);
      case 'booking_status':
      case 'booking_auto_completed':
        return const Color(0xFF10B981);
      case 'booking_cancelled':
      case 'booking_auto_cancelled':
        return const Color(0xFFEF4444);
      case 'payment':
        return const Color(0xFFF59E0B);
      case 'promo':
        return const Color(0xFF8B5CF6);
      case 'review':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => provider.markAllAsRead(),
                child: const Text('Mark all as read'),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null && provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(provider.error!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => provider.fetchNotifications(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Notifications Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your booking updates & alerts will appear here.',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(refresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = provider.notifications[index];
                return _buildNotificationCard(context, item, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel item,
    NotificationProvider provider,
  ) {
    final typeColor = _getColorForType(item.type);
    final typeIcon = _getIconForType(item.type);

    return InkWell(
      onTap: () {
        if (!item.isRead) {
          provider.markAsRead(item.id);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : typeColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead
                ? const Color(0xFFE2E8F0)
                : typeColor.withOpacity(0.3),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            if (!item.isRead)
              BoxShadow(
                color: typeColor.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(typeIcon, color: typeColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                item.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: typeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(item.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
