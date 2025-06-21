// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:LILI/services/task_service.dart';
import 'package:LILI/models/task.dart';
import 'navbar.dart'; // Import your Navbar
import 'package:LILI/pages/notifications_page.dart';
import '../services/notification_service.dart';
import 'package:LILI/user_session.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  int _currentIndex = 0; // Home Page is index 0
  bool _checkbox1 = false;
  bool _checkbox2 = false;
  bool _checkbox3 = false;

  List<NotificationModel> _latestNotifications = [];
  bool _dropdownOpen = false;
  bool _loadingNotifications = false;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.week;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    // Fetch tasks when the page loads
    Provider.of<TaskService>(context, listen: false).fetchTasks();
    _fetchNotifications();
  }

  void _fetchNotifications() async {
    setState(() => _loadingNotifications = true);
    try {
      final notifs = await NotificationService().fetchNotifications(UserSession().getUserId().toString());
      setState(() {
        _latestNotifications = notifs.take(5).toList();
        _loadingNotifications = false;
      });
    } catch (e) {
      setState(() => _loadingNotifications = false);
    }
  }

  // This function will be used for navigation when the navbar items are tapped
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Perform navigation based on the selected index
    if (index == 1) {
      Navigator.pushNamed(context, '/mainmenu'); // Navigate to MainMenu
    }
    if (index == 2) {
      Navigator.pushNamed(context, '/dash board '); // Navigate to EmergencyPage
    }
    if (index == 3) {
      Navigator.pushNamed(context, '/emergency'); // Navigate to EmergencyPage
    }
    if (index == 4) {
      Navigator.pushNamed(context, '/profile'); // Navigate to ProfilePage
    }
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
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
                colors: [
                  const Color(0xFF1F3354),
                  const Color(0xFF3E5879),
                ],
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white24,
                                  child: Icon(
                                    Icons.person,
                                    size: 35,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'Ganna',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Calendar Card
                          Card(
                            elevation: 8,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: TableCalendar(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                                calendarFormat: _calendarFormat,
                                onFormatChanged: (format) {
                                  setState(() {
                                    _calendarFormat = format;
                                  });
                                },
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                },
                                onPageChanged: (focusedDay) {
                                  _focusedDay = focusedDay;
                                },
                                headerStyle: const HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                calendarStyle: CalendarStyle(
                                  todayDecoration: BoxDecoration(
                                    color: const Color(0xFF1F3354).withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: const BoxDecoration(
                                    color: Color(0xFF1F3354),
                                    shape: BoxShape.circle,
                                  ),
                                  markersMaxCount: 1,
                                  outsideDaysVisible: false,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tasks Section
                          const Text(
                            'Today\'s Tasks',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTasksList(),
                        ],
                      ),
                    ),
                  ),
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
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Icon(FontAwesomeIcons.bell, size: 28, color: Colors.white),
                      ),
                      if (_latestNotifications.any((n) => !n.isRead))
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                            constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                            child: Text('!', style: TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
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
              else ..._latestNotifications.map((notif) => ListTile(
                leading: Icon(_iconForType(notif.type), color: notif.isRead ? Colors.grey : Colors.blue),
                title: Text(notif.title, style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold)),
                onTap: () async {
                  await NotificationService().markAsRead(notif.id);
                  _fetchNotifications();
                  setState(() => _dropdownOpen = false);
                  _handleNotificationTap(notif);
                },
              )),
              Divider(),
              TextButton.icon(
                icon: Icon(Icons.arrow_forward),
                label: Text('See all notifications'),
                onPressed: () {
                  setState(() => _dropdownOpen = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsPage(
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
      Navigator.pushNamed(context, '/task home', arguments: notif.data['task_id']);
    } else if (notif.type == 'recipe' && notif.data['recipe_id'] != null) {
      Navigator.pushNamed(context, '/Recipe', arguments: notif.data['recipe_id']);
    } else if (notif.type == 'inventory' && notif.data['item_name'] != null) {
      Navigator.pushNamed(context, '/inventory', arguments: notif.data['item_name']);
    } else if (notif.type == 'spending' && notif.data['category'] != null) {
      Navigator.pushNamed(context, '/budget home', arguments: notif.data['category']);
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

  Widget _buildTasksList() {
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        if (taskService.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        if (taskService.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.white38),
                SizedBox(height: 16),
                Text(
                  taskService.error!,
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => taskService.fetchTasks(),
                  child: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF1F3354),
                  ),
                ),
              ],
            ),
          );
        }

        final tasks = taskService.tasks;
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 48, color: Colors.white38),
                SizedBox(height: 16),
                Text(
                  'No tasks for today',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              color: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white24),
              ),
              child: ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    color: Colors.white,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  task.description,
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Checkbox(
                  value: task.isCompleted,
                  onChanged: (val) async {
                    if (val != null) {
                      final success = await taskService.updateTaskStatus(task, val);
                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update task status'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  checkColor: Colors.white,
                  fillColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.white24;
                      }
                      return Colors.transparent;
                    },
                  ),
                  side: BorderSide(color: Colors.white60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
