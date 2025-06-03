import 'package:flutter/material.dart';
import '../../../../models/user.dart';
import 'wave2.dart'; // <-- Import WaveClipper here
import 'package:LILI/pages/profile.dart'; // <-- Import ProfilePage here

class MoreInfoPage extends StatefulWidget {
  final User user;

  MoreInfoPage({required this.user});

  @override
  _MoreInfoPageState createState() => _MoreInfoPageState();
}

class _MoreInfoPageState extends State<MoreInfoPage> {
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
                      leading: Icon(
                        Icons.notification_important,
                        color: Color(0xFF3E5879),
                      ),
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
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(), // <-- Use the WaveClipper here
                  child: Container(height: 250, color: Color(0xFF213555)),
                ),
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFF213555), width: 4),
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoBlock("Name", widget.user.name),
                  _infoBlock("Email", widget.user.email),
                  _infoBlock("Phone", widget.user.phone),
                  _infoBlock("Date of Birth", widget.user.dob),
                  _infoBlock("Allergies", widget.user.allergies.join(", ")),
                ],
              ),
            ),
            GestureDetector(
              onTap: _navigateToless_info, // <-- Navigate to ProfilePage
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.transparent),
                child: Column(
                  children: [
                    Icon(Icons.arrow_upward, color: Color(0xFF213555)),
                    Text(
                      "Less Info",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF213555),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToless_info() {
    Navigator.pop(context); // <-- This will go back to the previous screen
  }

  Widget _infoBlock(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
