import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400,
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: const Color(0xFFF5EFE7)),
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 100,
                    child: Text(
                      'Log In',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF213555),
                        fontSize: 64,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 1.20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/hosting');
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
                'Log In',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login with face id ');
              },
              child: const Text('Log in using FaceID'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/forget password email');
              },
              child: const Text('Forget password?'),
            ),
          ],
        ),
      ),
    );
  }
}
