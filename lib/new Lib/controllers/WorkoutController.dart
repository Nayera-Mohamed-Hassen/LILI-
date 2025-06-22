import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WorkoutController extends GetxController {
  var age = ''.obs;
  var weight = ''.obs;
  var height = ''.obs;
  var fitnessGoal = ''.obs;
  var experience = ''.obs;
  var equipment = <String>[].obs;
  var limitations = ''.obs;
  var isLoading = false.obs;
  var workoutPlan = {}.obs;
  var errorMessage = ''.obs;
  RxList<Map<String, dynamic>> savedPlans = <Map<String, dynamic>>[].obs;

  void toggleEquipment(String item) {
    if (equipment.contains(item)) {
      equipment.remove(item);
    } else {
      equipment.add(item);
    }
  }

  final List<String> equipmentOptions = [
    'Dumbbells',
    'Resistance Bands',
    'Yoga Mat',
    'Jump Rope',
    'Kettlebells',
    'Pull-up Bar',
    'Stability Ball',
  ];

  final List<Map<String, dynamic>> popularPlans = [
    {
      'title': 'Push-Pull-Legs',
      'type': 'Strength',
      'icon': Icons.fitness_center,
      'color': Colors.orange,
      'description': 'Classic strength training split',
      'duration': '6 weeks',
      'daysPerWeek': 5,
      'details': {
        'overview':
            'The PPL split divides training into pushing movements (chest, shoulders, triceps), pulling movements (back, biceps), and leg days for balanced muscle development.',
        'days': [
          {
            'title': 'Push Day (Chest/Shoulders/Triceps)',
            'exercises': [
              'Bench Press: 4 sets x 6-8 reps',
              'Overhead Press: 3 sets x 8-10 reps',
              'Incline Dumbbell Press: 3 sets x 10-12 reps',
              'Lateral Raises: 3 sets x 12-15 reps',
              'Tricep Dips: 3 sets x 10-12 reps',
            ],
          },
          {
            'title': 'Pull Day (Back/Biceps)',
            'exercises': [
              'Deadlifts: 4 sets x 5 reps',
              'Pull-ups: 3 sets x 8-10 reps',
              'Bent-over Rows: 3 sets x 8-10 reps',
              'Face Pulls: 3 sets x 12-15 reps',
              'Barbell Curls: 3 sets x 10-12 reps',
            ],
          },
          {
            'title': 'Legs Day',
            'exercises': [
              'Squats: 4 sets x 6-8 reps',
              'Romanian Deadlifts: 3 sets x 8-10 reps',
              'Bulgarian Split Squats: 3 sets x 10-12 reps',
              'Leg Curls: 3 sets x 12-15 reps',
              'Calf Raises: 4 sets x 15-20 reps',
            ],
          },
        ],
      },
    },
    {
      'title': 'HIIT Burn',
      'type': 'Cardio',
      'icon': Icons.timer,
      'color': Colors.red,
      'description': 'High intensity interval training',
      'duration': '4 weeks',
      'daysPerWeek': 3,
      'details': {
        'overview':
            'This program alternates between short bursts of intense exercise and brief recovery periods to maximize fat burning and cardiovascular improvement.',
        'days': [
          {
            'title': 'Tabata Day',
            'exercises': [
              'Jump Squats: 20 sec work / 10 sec rest x 8 rounds',
              'Burpees: 20 sec work / 10 sec rest x 8 rounds',
              'Mountain Climbers: 20 sec work / 10 sec rest x 8 rounds',
              'Rest 1 minute between exercises',
            ],
          },
          {
            'title': 'Circuit Day',
            'exercises': [
              '30 sec Jump Rope',
              '30 sec Box Jumps',
              '30 sec Battle Ropes',
              '30 sec Medicine Ball Slams',
              'Repeat circuit 4x with 1 min rest between',
            ],
          },
          {
            'title': 'Endurance Day',
            'exercises': [
              '400m Run',
              '20 Air Squats',
              '20 Push-ups',
              'Repeat 5 rounds for time',
            ],
          },
        ],
      },
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedPlans();
  }

  Future<void> _loadSavedPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList('saved_plans');
    if (saved != null) {
      savedPlans.value =
          saved.map((e) => jsonDecode(e)).cast<Map<String, dynamic>>().toList();
    }
  }

  Future<void> generateWorkoutPlan() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      if (age.value.isEmpty ||
          weight.value.isEmpty ||
          height.value.isEmpty ||
          fitnessGoal.value.isEmpty ||
          experience.value.isEmpty) {
        throw Exception('Please fill all required fields');
      }
      // Generate a simple local plan (demo)
      workoutPlan.value = {
        'title': 'Custom Plan',
        'duration': '4 weeks',
        'intensity': 'Medium',
        'overview': 'A simple custom plan based on your input.',
        'bmi': 0,
        'days': [],
      };
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
