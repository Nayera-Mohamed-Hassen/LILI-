// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'navbar.dart'; // Import your Navbar

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

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.week;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
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
      body: Container(
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
                          _buildNotificationButton(),
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
    );
  }

  Widget _buildNotificationButton() {
    return GestureDetector(
      onTapDown: (details) {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            0,
            0,
          ),
          items: [
            PopupMenuItem(
              child: _buildNotificationItem(
                icon: Icons.notification_important,
                color: const Color(0xFF3E5879),
                title: 'Project UI is due today',
                subtitle: '2 hours remaining',
              ),
            ),
            PopupMenuItem(
              child: _buildNotificationItem(
                icon: Icons.new_releases,
                color: Colors.orange,
                title: 'New task assigned',
                subtitle: 'Check your tasks list',
              ),
            ),
          ],
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white24,
          border: Border.all(color: Colors.white38),
        ),
        child: Stack(
          children: [
            const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 28,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList() {
    return Column(
      children: [
        _buildTaskItem(
          "Load laundry",
          _checkbox1,
          (v) => setState(() => _checkbox1 = v ?? false),
          Icons.local_laundry_service,
        ),
        _buildTaskItem(
          "Sweep floors",
          _checkbox2,
          (v) => setState(() => _checkbox2 = v ?? false),
          Icons.cleaning_services,
        ),
        _buildTaskItem(
          "Do dishes",
          _checkbox3,
          (v) => setState(() => _checkbox3 = v ?? false),
          Icons.wash,
        ),
      ],
    );
  }

  Widget _buildTaskItem(String label, bool value, Function(bool?) onChanged, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1F3354).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1F3354)),
        ),
        title: Text(
          label,
          style: TextStyle(
            decoration: value ? TextDecoration.lineThrough : null,
            color: value ? Colors.grey : Colors.black87,
          ),
        ),
        trailing: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1F3354),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
