import 'package:flutter/material.dart';

class BroadcastPage extends StatelessWidget {
  const BroadcastPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EFE7), // same beige
      // const Color(0xFFF5EFE7)
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/LILI_logo.png', height: 261, width: 264),
              // SizedBox(height: 30),
              Text(
                'LILI',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF213555),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'A smart intelligent platform for home setup management',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF213555)),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signing');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3E5879),

                  // const Color(0xFF3E5879)
                  minimumSize: Size(315, 55),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
