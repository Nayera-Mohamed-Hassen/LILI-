import 'package:flutter/material.dart';
import 'pages/signing_page.dart';
import 'pages/login_page.dart';
import 'pages/broadcast_page.dart';
import 'pages/signup_page.dart';
import 'pages/hosting_page.dart';
import 'pages/joining_page.dart';
import 'pages/init_setup_page.dart';
import 'pages/forget_password_email_page.dart';
import 'pages/forget_password_reset_page.dart';
import 'pages/login_with_face_id_page.dart';
import 'pages/add_user_page.dart';
import 'pages/tasks_home_page.dart';

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
        scaffoldBackgroundColor: Color(0xFFF5EFE7),
        // beige background
      ),
      initialRoute: '/task home',
      routes: {
        '/': (context) => BroadcastPage(),
        '/signing': (context) => SigningPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/hosting': (context) => HostingPage(),
        '/joining': (context) => JoiningPage(),
        '/init setup': (context) => InitSetupPage(),
        '/forget password email': (context) => ForgetPasswordEmailPage(),
        '/forget password reset': (context) => ForgetPasswordResetPage(),
        '/login with face id ': (context) => LoginWithFaceIDPage(),
        '/add user': (context) => AddUserPage(),
        '/task home': (context) => TasksHomePage(),
      },
    );
  }
}
