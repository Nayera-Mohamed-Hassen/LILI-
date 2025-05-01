import 'package:flutter/material.dart';
import 'navbar.dart'; // Import the Navbar

class EmergencyPage extends StatefulWidget {
  @override
  _EmergencyPageState createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  int _currentIndex = 2; // Default to EmergencyPage when selected

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
      Navigator.pushNamed(context, '/homepage');// Navigate to HomePage
    } else if (index == 1) {
      Navigator.pushNamed(context, '/mainmenu'); // Navigate to MainMenuPage
   } else if (index == 3) {
      Navigator.pushNamed(context, '/profile'); // Navigate to ProfilePage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EFE7), // Beige background
      body: Center(
        child: Text(
          'Emergency Center',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: Navbar(
        page: _currentIndex, // Pass the current index to the Navbar
        onTap: _onTabTapped, // Handle tab selection in Navbar
      ),
    );
  }
}
