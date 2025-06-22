import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/WorkoutController.dart';

class WorkoutScreen extends StatelessWidget {
  final WorkoutController controller = Get.put(WorkoutController());

  WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.workoutPlan.isNotEmpty) {
          controller.workoutPlan.clear();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("AI Workout Planner"),
          actions: [
            if (controller.workoutPlan.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => controller.workoutPlan.clear(),
                tooltip: 'Create New Plan',
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Age'),
                onChanged: (value) => controller.age.value = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Weight'),
                onChanged: (value) => controller.weight.value = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Height'),
                onChanged: (value) => controller.height.value = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Fitness Goal'),
                onChanged: (value) => controller.fitnessGoal.value = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Experience'),
                onChanged: (value) => controller.experience.value = value,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.generateWorkoutPlan(),
                child: const Text('Generate Plan'),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.workoutPlan.isNotEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Title: ${controller.workoutPlan['title'] ?? ''}'),
                          Text('Duration: ${controller.workoutPlan['duration'] ?? ''}'),
                          Text('Intensity: ${controller.workoutPlan['intensity'] ?? ''}'),
                          Text('Overview: ${controller.workoutPlan['overview'] ?? ''}'),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
