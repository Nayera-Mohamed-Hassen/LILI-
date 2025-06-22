import 'package:LILI/main.dart';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:gif/gif.dart';
import 'package:LILI/pages/notifications_page.dart';
import '../services/notification_service.dart';
import 'package:LILI/user_session.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/notification.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainMenuPage());
  }
}

class MainMenuPage extends StatefulWidget {
  @override
  _MainMenuPageState createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  List<NotificationModel> _latestNotifications = [];
  bool _dropdownOpen = false;
  bool _loadingNotifications = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() async {
    setState(() => _loadingNotifications = true);
    try {
      final notifs = await NotificationService().fetchNotifications(
        UserSession().getUserId().toString(),
      );
      setState(() {
        _latestNotifications = notifs.take(5).toList();
        _loadingNotifications = false;
      });
    } catch (e) {
      setState(() => _loadingNotifications = false);
    }
  }

  Widget _buildNotificationDropdown() {
    return Positioned(
      right: 10,
      top: 60,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 320,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loadingNotifications)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              else if (_latestNotifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('No notifications'),
                )
              else
                ..._latestNotifications.map(
                  (notif) => ListTile(
                    leading: Icon(
                      _iconForType(notif.type),
                      color: notif.isRead ? Colors.grey : Colors.blue,
                    ),
                    title: Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight:
                            notif.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    onTap: () async {
                      await NotificationService().markAsRead(notif.id);
                      _fetchNotifications();
                      setState(() => _dropdownOpen = false);
                      _handleNotificationTap(notif);
                    },
                  ),
                ),
              Divider(),
              if (_latestNotifications.any((n) => !n.isRead))
                TextButton.icon(
                  icon: Icon(Icons.mark_email_read),
                  label: Text('Mark All as Read'),
                  onPressed: () async {
                    final userId = UserSession().getUserId().toString();
                    final success = await NotificationService().markAllAsRead(
                      userId,
                    );
                    if (success) {
                      _fetchNotifications();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('All notifications marked as read!'),
                        ),
                      );
                    }
                  },
                ),
              TextButton.icon(
                icon: Icon(Icons.arrow_forward),
                label: Text('See all notifications'),
                onPressed: () {
                  setState(() => _dropdownOpen = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => NotificationsPage(
                            userId: UserSession().getUserId().toString(),
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notif) {
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

  IconData _iconForType(String type) {
    switch (type) {
      case 'task':
        return FontAwesomeIcons.clipboardCheck;
      case 'recipe':
        return FontAwesomeIcons.utensils;
      case 'inventory':
        return FontAwesomeIcons.boxOpen;
      case 'spending':
        return FontAwesomeIcons.wallet;
      case 'system':
        return FontAwesomeIcons.userEdit;
      default:
        return FontAwesomeIcons.bell;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF1F3354), const Color(0xFF3E5879)],
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(width: 1), // Placeholder for alignment
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(230),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Menuitem(
                            onPressed: () {
                              Navigator.pushNamed(context, '/task home');
                            },
                            text: "View Tasks",
                            image: "assets/images/tasks.gif",
                          ),
                          Menuitem(
                            onPressed: () {
                              Navigator.pushNamed(context, '/Recipe');
                            },
                            text: "Suggests Recipe",
                            image: "assets/images/food.gif",
                          ),
                          Menuitem(
                            onPressed: () {
                              Navigator.pushNamed(context, '/inventory');
                            },
                            text: "Show Inventory",
                            image: "assets/images/inventory.gif",
                          ),
                          Menuitem(
                            onPressed: () {
                              Navigator.pushNamed(context, '/Expenses ');
                            },
                            text: "Track Expenses",
                            image: "assets/images/money.gif",
                          ),
                          // Menuitem(
                          //   onPressed: () {
                          //     Navigator.pushNamed(context, '/workout_planner');
                          //   },
                          //   text: "Workout Planner",
                          //   image: "assets/images/food.gif",
                          // ),
                          Menuitem(
                            onPressed: () {
                              Navigator.pushNamed(context, '/family_calendar');
                            },
                            text: "Family Calendar",
                            image: "assets/images/calendar.gif",
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // Notification bell and dropdown overlay
          Positioned(
            top: 30,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => _dropdownOpen = !_dropdownOpen);
                    if (!_dropdownOpen) _fetchNotifications();
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          FontAwesomeIcons.bell,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      if (_latestNotifications.any((n) => !n.isRead))
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_dropdownOpen) _buildNotificationDropdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String text, String route) {
    return SizedBox(
      width: 140,
      height: 150,
      child: PrimaryButton(
        onPressed: () {
          Navigator.pushNamed(context, route); // Navigate to respective screen
        },
        text: text,
      ),
    );
  }
}

class Menuitem extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final String image;

  const Menuitem({
    required this.onPressed,
    required this.text,
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 50),
        GestureDetector(
          onTap: this.onPressed,
          child: Container(
            width: 330,
            height: 91,
            decoration: ShapeDecoration(
              color: const Color(0xFF3E5879),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(color: Color(0xFF213555), width: 3),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 8,
                  top: 36,
                  child: SizedBox(
                    width: 313,
                    child: Text(
                      this.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFF2F2F2),
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 251,
                  top: 46,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF2F2F2),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 3,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: const Color(0xFF213555),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        //Icons.play_circle_outline,
                        Icons.play_arrow_outlined,
                        size: 60,
                        color: Color(0xFF213555),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: -19,
                  child: Container(
                    width: 69,
                    height: 69,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF2F2F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            child: GifView.asset(
                              this.image,
                              height: 200,
                              width: 200,
                              frameRate: 25,
                            ),
                            width: 70,
                            height: 70,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 3,
                                  color: const Color(0xFF213555),
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
