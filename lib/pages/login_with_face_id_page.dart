import 'package:flutter/material.dart';

class LoginWithFaceIDPage extends StatelessWidget {
  const LoginWithFaceIDPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(child: Icon(Icons.face, size: 80, color: Color(0xFF3A4F63))),
    );
  }
}
