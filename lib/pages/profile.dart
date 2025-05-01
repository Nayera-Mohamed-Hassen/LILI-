import 'package:flutter/material.dart';
import 'navbar.dart'; // Import the Navbar

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3; // Default to ProfilePage when selected

  // Pages to display based on navigation bar selection
  final List<Widget> _pages = [
    Center(child: Text('Home Page Content')),
    Center(child: Text('Main Menu Content')),
    Center(child: Text('Emergency Content')),
    Center(child: Text('Profile Content')), // Profile page content
  ];

  // Function to handle tab navigation
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index; // Update the current index based on tab selection
    });

    // Navigation based on index
    if (index == 0) {
      Navigator.pushNamed(context, '/homepage'); // Navigate to HomePage
    } else if (index == 1) {
      Navigator.pushNamed(context, '/mainmenu'); // Navigate to MainMenuPage
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
      body: Center(
        child: Text(
          'User Profile', // Profile content
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
