import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  final String userId;

  const NotificationsPage({required this.userId, Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<NotificationModel>> _notificationsFuture;
  final NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationsFuture = notificationService.fetchNotifications(
      widget.userId,
    );
  }

  void _refresh() {
    setState(() {
      _notificationsFuture = notificationService.fetchNotifications(
        widget.userId,
      );
    });
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'task':
        return Icons.assignment;
      case 'recipe':
        return Icons.restaurant_menu;
      case 'inventory':
        return Icons.inventory;
      case 'spending':
        return Icons.attach_money;
      default:
        return Icons.notifications;
    }
  }

  void _onNotificationTap(NotificationModel notif) {
    if (notif.type == 'task' && notif.data['task_id'] != null) {
      Navigator.pushNamed(
        context,
        '/task home',
        arguments: notif.data['task_id'],
      );
    } else if (notif.type == 'recipe' && notif.data['recipe_id'] != null) {
      Navigator.pushNamed(
        context,
        '/Recipe',
        arguments: notif.data['recipe_id'],
      );
    } else if (notif.type == 'inventory' && notif.data['item_name'] != null) {
      Navigator.pushNamed(
        context,
        '/inventory',
        arguments: notif.data['item_name'],
      );
    } else if (notif.type == 'spending' && notif.data['category'] != null) {
      Navigator.pushNamed(
        context,
        '/Expenses ',
        arguments: notif.data['category'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1F3354), const Color(0xFF3E5879)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<NotificationModel>>(
            future: _notificationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading notifications',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No notifications.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              final notifications = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return Dismissible(
                    key: Key(notif.id),
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 20),
                      child: Icon(Icons.mark_email_read, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd &&
                          !notif.isRead) {
                        await notificationService.markAsRead(notif.id);
                        _refresh();
                        return false;
                      } else if (direction == DismissDirection.endToStart) {
                        await notificationService.deleteNotification(notif.id);
                        _refresh();
                        return true;
                      }
                      return false;
                    },
                    child: Card(
                      color:
                          notif.isRead
                              ? Colors.white24
                              : Colors.white.withOpacity(0.85),
                      elevation: notif.isRead ? 0 : 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          _iconForType(notif.type),
                          color: notif.isRead ? Colors.grey : Colors.blue,
                        ),
                        title: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight:
                                notif.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                            color: notif.isRead ? Colors.white70 : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          notif.body,
                          style: TextStyle(
                            color:
                                notif.isRead ? Colors.white54 : Colors.black87,
                          ),
                        ),
                        trailing:
                            notif.isRead
                                ? null
                                : Icon(Icons.fiber_new, color: Colors.red),
                        onTap: () async {
                          if (!notif.isRead) {
                            await notificationService.markAsRead(notif.id);
                            _refresh();
                          }
                          _onNotificationTap(notif);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
