import 'package:flutter/material.dart';

class MyCardPage extends StatefulWidget {
  @override
  State<MyCardPage> createState() => _MyCardPageState();
}

class _MyCardPageState extends State<MyCardPage> {
  final Color blueCard = Color(0xFF213555);
  final Color greenCard = Color(0xFFB2EBF2);
  final Color blackCard = Color(0xFF263238);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EFE7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "My Card",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildCard(
                greenCard,
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
        Icon(Icons.nfc, color: isLight ? Colors.black : Colors.white),
        SizedBox(height: 16),
        Text(
          number,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isLight ? Colors.black : Colors.white,
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                color: isLight ? Colors.black87 : Colors.white70,
                fontSize: 14,
              ),
            ),
            Text(
              "Exp $expDate",
              style: TextStyle(
                color: isLight ? Colors.black54 : Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
