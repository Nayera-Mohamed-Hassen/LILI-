import 'package:LILI/main.dart';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:gif/gif.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1F3354),
              const Color(0xFF3E5879),
            ],
          ),
        ),
        child: Center(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 50, width: MediaQuery.of(context).size.width),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white24,
                            border: Border.all(color: Colors.white38),
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(230),
                    ),
                  ),

                  SizedBox(height: 40),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Menuitem(
                            onPressed: () {
                              Navigator.pushNamed(context, '/task home');
                            },
                            text: "View Tasks",
                            image: "assets/images/tasks.gif",
                          ),

                          Menuitem(
                            onPressed: () {
                              Navigator.pushNamed(context, '/Recipe');
                            },
                            text: "Suggests Recipe",
                            image: "assets/images/food.gif",
                          ),

                          Menuitem(
                            onPressed: () {
                              Navigator.pushNamed(context, '/inventory');
                            },
                            text: "Show Inventory",
                            image: "assets/images/inventory.gif",
                          ),

                          Menuitem(
                            onPressed: () {
                              Navigator.pushNamed(context, '/Expenses ');
                            },
                            text: "Track Expenses",
                            image: "assets/images/money.gif",
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
        ),
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

class Menuitem extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final String image;

  const Menuitem({
    required this.onPressed,
    required this.text,
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 50),
        GestureDetector(
          onTap: this.onPressed,
          child: Container(
            width: 330,
            height: 91,
            decoration: ShapeDecoration(
              color: const Color(0xFF3E5879),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(color: Color(0xFF213555), width: 3),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 8,
                  top: 36,
                  child: SizedBox(
                    width: 313,
                    child: Text(
                      this.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFF2F2F2),
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 251,
                  top: 46,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF2F2F2),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 3,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: const Color(0xFF213555),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        //Icons.play_circle_outline,
                        Icons.play_arrow_outlined,
                        size: 60,
                        color: Color(0xFF213555),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: -19,
                  child: Container(
                    width: 69,
                    height: 69,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF2F2F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            child: GifView.asset(
                              this.image,
                              height: 200,
                              width: 200,
                              frameRate: 25,
                            ),
                            width: 70,
                            height: 70,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 3,
                                  color: const Color(0xFF213555),
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
