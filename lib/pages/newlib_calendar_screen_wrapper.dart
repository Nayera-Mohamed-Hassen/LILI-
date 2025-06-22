import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../new Lib/views/screens/calendar_screen.dart';

class NewLibCalendarScreenWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalendarScreen(),
    );
  }
} 