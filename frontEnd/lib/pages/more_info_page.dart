import 'package:flutter/material.dart';
import '../models/user.dart';
import 'wave.dart';

class MoreInfoPage extends StatelessWidget {
  final User user;

  MoreInfoPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF213555),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () => print('Notification icon pressed'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: CustomClipPath(),
              child: Container(
                height: 150,
                width: double.infinity,
                color: Color(0xFF213555),
                alignment: Alignment.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  _infoBlock("Name", user.name),
                  _infoBlock("Email", user.email),
                  _infoBlock("Phone", user.phone),
                  _infoBlock("Date of Birth", user.dob),
                  _infoBlock("Address", user.address),
                  _infoBlock("Allergies", user.allergies.join(", ")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBlock(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}