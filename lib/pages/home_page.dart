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

  int _currentIndex = 0; // Home Page is index 0
  bool _checkbox1 = false;
  bool _checkbox2 = false;
  bool _checkbox3 = false;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
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
      Navigator.pushNamed(context, '/emergency'); // Navigate to EmergencyPage
    }
    if (index == 3) {
      Navigator.pushNamed(context, '/profile'); // Navigate to ProfilePage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/homepage.png',
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(radius: 40),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning!',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF2F2F2),
                          ),
                        ),
                        Text(
                          'Ganna',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF2F2F2),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
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
                              child: ListTile(
                                leading: Icon(
                                  Icons.notification_important,
                                  color: Color(0xFF3E5879),
                                ),
                                title: Text('Project UI is due today.'),
                              ),
                            ),
                            PopupMenuItem(
                              child: ListTile(
                                leading: Icon(
                                  Icons.new_releases,
                                  color: Colors.orange,
                                ),
                                title: Text('New task assigned.'),
                              ),
                            ),
                          ],
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1F3354),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: Color(0xFFF2F2F2),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Tasks Section
                Text(
                  'Tasks:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E5879),
                  ),
                ),

                // SizedBox(height: 8),
                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildTaskItem(
                      "load laundry",
                      _checkbox1,
                      (v) => setState(() => _checkbox1 = v ?? false),
                    ),
                    _buildTaskItem(
                      "sweep floors",
                      _checkbox2,
                      (v) => setState(() => _checkbox2 = v ?? false),
                    ),
                    _buildTaskItem(
                      "do dishes",
                      _checkbox3,
                      (v) => setState(() => _checkbox3 = v ?? false),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Calendar Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.black),
                      weekendStyle: TextStyle(color: Colors.black),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Color(0xFF3E5879),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFF3E5879),
                        shape: BoxShape.circle,
                      ),
                      defaultDecoration: BoxDecoration(shape: BoxShape.circle),
                      weekendDecoration: BoxDecoration(shape: BoxShape.circle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String label, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: CheckboxListTile(
          title: Text(label),
          value: value,
          onChanged: onChanged,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
          visualDensity: VisualDensity.compact,

          activeColor: Color(0xFF1F3354),
        ),
      ),
    );
  }
}
