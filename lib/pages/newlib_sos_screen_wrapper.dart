import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../new Lib/views/screens/sos_screen.dart';

class NewLibSosScreenWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SosScreen(),
    );
  }
} 