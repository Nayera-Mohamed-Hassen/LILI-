import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../new Lib/views/screens/workout_screen.dart';

class NewLibWorkoutScreenWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: WorkoutScreen(),
    );
  }
} 