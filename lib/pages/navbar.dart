// lib/navbar.dart
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'home_page.dart';
import 'main_menu.dart';
import 'emergency.dart';
import 'profile.dart';
import 'dash_board_page.dart';

class Navbar extends StatefulWidget {
  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _pageIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    MainMenuPage(),
    ReportDashboard(),
    EmergencyPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Color(0xFFF2F2F2)),
          Icon(Icons.menu, size: 30, color: Color(0xFFF2F2F2)),
          Icon(Icons.dashboard_outlined, size: 30, color: Color(0xFFF2F2F2)),
          Icon(Icons.warning_amber_rounded, size: 30, color: Color(0xFFF2F2F2)),
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
