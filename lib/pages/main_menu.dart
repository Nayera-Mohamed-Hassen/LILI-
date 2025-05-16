import 'package:LILI/main.dart';
import 'package:flutter/material.dart';
import 'package:LILI/pages/tasks_home_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainMenuPage());
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
      // Beige background
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/homepage.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width - 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  // Aligns the icon to the right
                  children: [
                    Icon(
                      Icons.notifications,
                      color: Color(0xFFF2F2F2),
                      size: 50,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width - 30,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search features...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
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
                          buildButton("Show Expenses", '/budget'),
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
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildButton(String text, String route) {
    return SizedBox(
      width: 140,
      height: 150,
      child: PrimaryButton(
        onPressed: () {
          Navigator.pushNamed(context, route); // Navigate to respective screen
        },
        text: text,
      ),
    );
  }
}
