import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../new Lib/views/screens/sos_screen.dart';
import '../new Lib/controllers/home_controller.dart';
import '../new Lib/core/services/notification_service.dart';

class NewLibSosScreenWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationService>()) {
      Get.put(NotificationService(), permanent: true);
    }
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    }
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SosScreen(),
    );
  }
} 