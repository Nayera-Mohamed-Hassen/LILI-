import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../new Lib/views/screens/workout_screen.dart';
import '../new Lib/controllers/WorkoutController.dart';
import '../new Lib/controllers/home_controller.dart';
import '../new Lib/core/services/notification_service.dart';

class NewLibWorkoutScreenWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationService>()) {
      Get.put(NotificationService(), permanent: true);
    }
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    }
    if (!Get.isRegistered<WorkoutController>()) {
      Get.put(WorkoutController());
    }
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: WorkoutScreen(),
    );
  }
} 