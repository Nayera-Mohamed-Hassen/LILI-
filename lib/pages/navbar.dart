// lib/navbar.dart
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'home_page.dart';
import 'main_menu.dart';
import 'emergency.dart';
import 'profile.dart';
import 'dash_board_page.dart';
import '../user_session.dart';
import 'newlib_sos_screen_wrapper.dart';
import 'package:LILI/new Lib/views/screens/sos_screen.dart';

class Navbar extends StatefulWidget {
  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _pageIndex = 0;
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = UserSession().getUserId().toString();
  }

  List<Widget> get _pages => [
    HomePage(),
    MainMenuPage(),
    ReportDashboard(userId: userId),
    SosScreen(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex,
        height: 60.0,
        items: <Widget>[
          IconButton(
            key: Key('home_button'),
            onPressed: () {/* TODO: implement navigation to home */},
            icon: Icon(Icons.home, size: 30, color: Color(0xFFF2F2F2)),
          ),
          IconButton(
            key: Key('calendar_button'),
            onPressed: () {/* TODO: implement navigation to calendar */},
            icon: Icon(Icons.calendar_today, size: 30, color: Color(0xFFF2F2F2)),
          ),
          IconButton(
            key: Key('inventory_button'),
            onPressed: () {/* TODO: implement navigation to inventory */},
            icon: Icon(Icons.inventory, size: 30, color: Color(0xFFF2F2F2)),
          ),
          IconButton(
            key: Key('emergency_button'),
            onPressed: () {/* TODO: implement navigation to emergency */},
            icon: Icon(Icons.warning, size: 30, color: Color(0xFFF2F2F2)),
          ),
          Icon(Icons.settings, size: 30, color: Color(0xFFF2F2F2)),
        ],
        color: Color(0xFF1F3354),
        buttonBackgroundColor: Color(0xFF1F3354),
        backgroundColor: Color(0xFF3E5879),
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}
