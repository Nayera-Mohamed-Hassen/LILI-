import 'package:flutter/material.dart';
import 'pages/signing_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/hosting_page.dart';
import 'pages/joining_page.dart';
import 'pages/init_setup_page.dart';
import 'pages/broadcast_page.dart';

void main() {
  runApp(LiliApp());
}

class LiliApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LILI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF5F0E8), // beige background
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => BroadcastPage(),
        '/signing': (context) => SigningPage(),
        //   '/login': (context) => LoginPage(),
        //   '/signup': (context) => SignUpPage(),
        //   '/hosting': (context) => HostingPage(),
        //   '/joining': (context) => JoiningPage(),
        //   '/initsetup': (context) => InitSetupPage(),
      },
    );
  }
}
