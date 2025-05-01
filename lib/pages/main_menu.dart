import 'package:flutter/material.dart';
import 'navbar.dart'; // Import the navbar

class MainMenuPage extends StatefulWidget {
  @override
  _MainMenuPageState createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _currentIndex = 1; // Default to MainMenuPage when selected

  // Pages to display based on navigation bar selection
  final List<Widget> _pages = [
    Center(child: Text('Home Page Content')),
    Center(child: Text('Main Menu Content')),
    Center(child: Text('Emergency Content')),
    Center(child: Text('Profile Content')),
  ];

  // Function to handle tab navigation
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index; // Update the current index based on tab selection
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/homepage'); // Navigate to HomePage
    } else if (index == 1) {
      Navigator.pushNamed(context, '/mainmenu'); // Stay on MainMenuPage
    } else if (index == 2) {
      Navigator.pushNamed(context, '/emergency'); // Navigate to EmergencyPage
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile'); // Navigate to ProfilePage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EFE7), // Beige background

      body: _pages[_currentIndex], // Show corresponding content based on selected tab

      bottomNavigationBar: Navbar(
        page: _currentIndex, // Pass the current index to the Navbar
        onTap: _onTabTapped, // Handle tab selection in Navbar
      ),
    );
  }
}
