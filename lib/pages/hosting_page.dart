import 'package:flutter/material.dart';

class HostingPage extends StatelessWidget {
  const HostingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/host house');
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
                'Host House',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/joining');
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
                'Join House',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
