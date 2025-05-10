import 'package:flutter/material.dart';
import 'navbar.dart';
import 'package:untitled4/models/user.dart';
import 'package:untitled4/pages/more_info_page.dart';
import 'package:untitled4/pages/edit_profile_page.dart';
import 'package:untitled4/pages/wave2.dart'; // <-- Import WaveClipper here
import 'package:untitled4/pages/signing_page.dart';
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3;

  final List<Widget> _pages = [
    Center(child: Text('Home Page Content')),
    Center(child: Text('Main Menu Content')),
    Center(child: Text('Emergency Content')),
    Center(child: Text('Profile Content')),
  ];

  User user = User(
    name: "Farah",
    email: "farah@home.com",
    dob: "Mar 25, 2006",
    phone: "+91 956232134",
    address:
    "99, Haji Abduakar Chawl, Dharavi Cross Rd, Kutti Wadi, Dharavi, Maharashtra",
    allergies: ["shrimp", "strawberries"],
  );

  void updateUser(User updatedUser) {
    setState(() {
      user = updatedUser;
    });
  }
  void _navigateTosigning_page() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SigningPage(),
      ),
    );
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () {
                Navigator.of(context).pop();
                print("User logged out");
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF213555),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
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
                      leading: Icon(Icons.notification_important, color: Color(0xFF3E5879)),
                      title: Text('Project UI is due today.'),
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.new_releases, color: Colors.orange),
                      title: Text('New task assigned.'),
                    ),
                  ),
                ],
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.notifications, color: Colors.white),
            ),
          ),
        ],
      ),
      //backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 250,
                    color: Color(0xFF213555),
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
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
                ),
              ],
            ),
            Container(
              width: 291,
              height: 130,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 110.86,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name',
                              style: TextStyle(
                                  color: Color(0xFF1D2345),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter')),
                          Text(user.name,
                              style: TextStyle(
                                  color: Color(0xFF3E5879),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Inter')),
                          SizedBox(height: 4),
                          Text('Date of Birth',
                              style: TextStyle(
                                  color: Color(0xFF1D2345),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter')),
                          Text(user.dob,
                              style: TextStyle(
                                  color: Color(0xFF3E5879),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Inter')),
                          SizedBox(height: 4),
                          Text('Phone',
                              style: TextStyle(
                                  color: Color(0xFF1D2345),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter')),
                          Text(user.phone,
                              style: TextStyle(
                                  color: Color(0xFF3E5879),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Inter')),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 129.33,
                    top: 0,
                    child: Container(
                      width: 161.67,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email',
                              style: TextStyle(
                                  color: Color(0xFF1D2345),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter')),
                          Text(user.email,
                              style: TextStyle(
                                  color: Color(0xFF3E5879),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Inter')),
                          SizedBox(height: 4),
                          Text('Address',
                              style: TextStyle(
                                  color: Color(0xFF1D2345),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter')),
                          SizedBox(
                            width: 161.67,
                            child: Text(
                              user.address,
                              style: TextStyle(
                                  color: Color(0xFF3E5879),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Inter'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _navigateToMoreInfo,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.transparent),
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
            SizedBox(height: 5),
            ElevatedButton.icon(
              onPressed: _navigateToEditProfile,
              icon: Icon(Icons.edit),
              label: Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF213555),
                foregroundColor: Colors.white,
                fixedSize: Size(260, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _navigateTosigning_page,
              icon: Icon(Icons.logout),
              label: Text("Log Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF213555),
                foregroundColor: Colors.white,
                fixedSize: Size(260, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
