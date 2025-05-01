// lib/pages/main_menu.dart

import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class MainMenuPage extends StatefulWidget {
  @override
  _MainMenuPageState createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _currentIndex = 1;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/home'); // Navigate back to HomePage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EFE7), // Beige background
      body: Center(child: Text("Main Menu Content")),
      // bottomNavigationBar: BottomNavBar(
      //   currentIndex: _currentIndex,
      //   onTabTapped: _onTabTapped,
      // ),
    );
  }
}