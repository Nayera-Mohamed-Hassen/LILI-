import 'package:flutter/material.dart';

class ForgetPasswordEmailPage extends StatelessWidget {
  const ForgetPasswordEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 400,
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: const Color(0xFFF5EFE7)),
              child: Stack(
                children: [
                  Positioned(
                    // left: 20,
                    top: 100,
                    child: Text(
                      'Forget Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF213555),
                        fontSize: 44,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 1.20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(labelText: 'Enter email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
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
                'Continue',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
