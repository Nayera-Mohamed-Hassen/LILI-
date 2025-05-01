import 'package:flutter/material.dart';
import 'package:untitled4/pages/emergency.dart';
import 'package:untitled4/pages/home_page.dart';
import 'package:untitled4/pages/main_menu.dart';
import 'package:untitled4/pages/profile.dart';
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
import 'pages/navbar.dart'; // Import the navbar

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
        scaffoldBackgroundColor: Color(0xFFF5EFE7), // beige background
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => BroadcastPage(),
        '/homepage': (context) => HomePage(),
        '/mainmenu': (context) => MainMenuPage(),
        '/emergency' :(context) => EmergencyPage(),
        '/profile' :(context) => ProfilePage(),
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
