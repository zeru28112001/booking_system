import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/notification/providers/notification_provider.dart';

class NotificationBellIconButton extends StatefulWidget {
  const NotificationBellIconButton({super.key, this.iconColor});

  final Color? iconColor;

  @override
  State<NotificationBellIconButton> createState() => _NotificationBellIconButtonState();
}

class _NotificationBellIconButtonState extends State<NotificationBellIconButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationProvider>().fetchNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final unread = provider.unreadCount;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                unread > 0 ? Icons.notifications_active_rounded : Icons.notifications_outlined,
                color: widget.iconColor ?? Theme.of(context).iconTheme.color,
              ),
              tooltip: 'Notifications',
              onPressed: () {
                context.push('/notifications');
              },
            ),
            if (unread > 0)
              Positioned(
                top: 8,
                right: 8,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
