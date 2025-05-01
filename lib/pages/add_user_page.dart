import 'package:flutter/material.dart';

class AddUserPage extends StatelessWidget {
  const AddUserPage({super.key});

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
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/img.png', height: 200),
            const SizedBox(height: 20),
            const Text('Join Code: 123456', style: TextStyle(fontSize: 18)),
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
                'Refresh Code',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/homepage');
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
                'Confirm',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
