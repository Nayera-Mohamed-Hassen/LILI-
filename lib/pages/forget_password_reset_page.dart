import 'package:flutter/material.dart';

class ForgetPasswordResetPage extends StatelessWidget {
  const ForgetPasswordResetPage({super.key});

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
                    top: 100,
                    child: Text(
                      'Reset Password',
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

            const TextField(
              decoration: InputDecoration(labelText: 'Enter new password'),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(labelText: 'Confirm new password'),
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
                'Discard Changes',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
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
                'Save Changes',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
