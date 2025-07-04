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
          Icon(
            Icons.home,
            size: 30,
            color: Color(0xFFF2F2F2),
            key: const Key('home_button'),
          ),
          Icon(
            Icons.menu,
            size: 30,
            color: Color(0xFFF2F2F2),
            key: const Key('menu_button'),
          ),
          Icon(
            Icons.dashboard_outlined,
            size: 30,
            color: Color(0xFFF2F2F2),
            key: const Key('dashboard_button'),
          ),
          Icon(
            Icons.warning_amber_rounded,
            size: 30,
            color: Color(0xFFF2F2F2),
            key: const Key('sos_button'),
          ),
          Icon(
            Icons.settings,
            size: 30,
            color: Color(0xFFF2F2F2),
            key: const Key('settings_button'),
          ),
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
