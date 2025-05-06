import 'package:flutter/material.dart';
import 'navbar.dart'; // Import the Navbar
import'package:untitled4/models/user.dart';
import 'package:untitled4/pages/more_info_page.dart';
import 'package:untitled4/pages/edit_profile_page.dart';
import 'package:untitled4/pages/wave.dart';
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

  User user = User(
    name: "Farah",
    email: "farah@home.com",
    dob: "Mar 25, 2006",
    phone: "+91 956232134",
    address: "99, Haji Abduakar Chawl, Dharavi Cross Rd, Kutti Wadi, Dharavi, Maharashtra",
    allergies: ["shrimp", "strawberries"],
  );


  void updateUser(User updatedUser) {
    setState(() {
      user = updatedUser;
    });
  }

  void _navigateToMoreInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoreInfoPage(user: user),
      ),
    );
  }

  void _navigateToEditProfile() async {
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: user),
      ),
    );

    if (updatedUser != null) {
      updateUser(updatedUser);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Color(0xFF213555),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              print('Notification icon pressed');
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            ClipPath(
              clipper: CustomClipPath(), // Changed clipper here
              child: Container(
                height: 150,
                color: Color(0xFF213555),
                padding: EdgeInsets.only(top: 20),
              ),
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF213555),
                    width: 4,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/Hana.jpeg'),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              user.name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(user.email, style: TextStyle(fontSize: 18, color: Color(0xFF213555))),
            Text(user.phone, style: TextStyle(fontSize: 18, color: Color(0xFF213555))),
            SizedBox(height: 30),

            GestureDetector(
              //onTap: onMoreInfoPressed,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Column(
                  children: [
                    Text(
                      "More Info",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF213555),
                      ),
                    ),
                    Icon(Icons.arrow_downward, color: Color(0xFF213555)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () async {
                final updatedUser = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      body: EditProfilePage(user: user),
                    ),
                  ),
                );
                if (updatedUser != null && updatedUser is User) {
                  //onEdit(updatedUser);
                }
              },
              icon: Icon(Icons.edit),
              label: Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF213555),
                foregroundColor: Colors.white,
                fixedSize: Size(260, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),

            ElevatedButton.icon(
              onPressed: () {
                // Implement logout logic here
              },
              icon: Icon(Icons.logout),
              label: Text("Log Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF213555),
                foregroundColor: Colors.white,
                fixedSize: Size(260, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
