import 'package:flutter/material.dart';

class MyCardPage extends StatefulWidget {
  @override
  State<MyCardPage> createState() => _MyCardPageState();
}

class _MyCardPageState extends State<MyCardPage> {
  final Color blueCard = Color(0xFF213555);
  final Color greenCard = Color(0xFFB2EBF2);
  final Color blackCard = Color(0xFF2A3F47);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EFE7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  BackButton(color: Color(0xFF213555)),
                  CircleAvatar(radius: 40),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning!',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF213555),
                        ),
                      ),
                      Text(
                        'Sandra',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF213555),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
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
                              title: Text('You exceeded the card limit.'),
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(
                                Icons.new_releases,
                                color: Colors.orange,
                              ),
                              title: Text('New task assigned.'),
                            ),
                          ),
                        ],
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF213555),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: Color(0xFFF5EFE7),
                      ),
                    ),
                  ),
                ],
              ),
              // Text(
              //   "My Card",
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
              SizedBox(height: 20),
              _buildCard(
                blueCard,
                "1253 5432 3521 3090",
                "Sarah Muller",
                "09/24",
                isLight: true,
              ),
              SizedBox(height: 16),
              _buildCard(
                blackCard,
                "1253 5432 3521 3090",
                "Sarah Muller",
                "09/24",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildCard(
  Color color,
  String number,
  String name,
  String expDate, {
  bool isLight = false,
}) {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.nfc, color: Colors.white),
        SizedBox(height: 16),
        Text(
          number,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: TextStyle(color: Colors.white, fontSize: 14)),
            Text(
              "Exp $expDate",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ],
    ),
  );
}
