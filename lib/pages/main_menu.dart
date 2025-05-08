import 'package:flutter/material.dart';
import 'package:untitled4/pages/tasks_home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainMenuPage()
    );
  }
}

class MainMenuPage extends StatefulWidget {
  @override
  _MainMenuPageState createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EFE7), // Beige background
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.notifications, color: Color(0xFF3E5879), size: 50),
            ],
          ),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search features...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: Icon(Icons.filter_list),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(child:
          SingleChildScrollView(child:Column(
            children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildButton("View Tasks", '/task home'),
                buildButton("Recommend Recipe", '/Recipe'),
              ],
            ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Show Inventory", '/inventory'),
                  buildButton("Show Expenses", '/'),
                ],
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Add To Shopping List", '/'),
                  buildButton("Open Calendar", '/'),
                ],
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton("Show Workout Plan", '/'),
                  buildButton("Show Family Map", '/'),
                ],
              ),],
          ) ,
          ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget buildButton(String text, String route) {
    return SizedBox(
      width: 140,
      height: 150,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route); // Navigate to respective screen
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1F3354),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text,style: TextStyle(fontWeight: FontWeight.bold,) ,textAlign: TextAlign.center,)
       ,),
    );
  }
}


