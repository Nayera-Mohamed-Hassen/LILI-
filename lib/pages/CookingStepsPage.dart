import 'package:flutter/material.dart';
import 'package:LILI/pages/navbar.dart';
import 'package:LILI/user_session.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'wave2.dart';
import '../config.dart';

class CookingStepsPage extends StatefulWidget {
  final String image;
  final List<String> steps;
  final String recipeName;
  final List<String> ingredients;
  final String mealType;
  final String timeTaken;

  const CookingStepsPage({
    required this.image, 
    required this.steps, 
    required this.recipeName,
    required this.ingredients,
    required this.mealType,
    required this.timeTaken,
    Key? key
  }) : super(key: key);

  @override
  _CookingStepsPageState createState() => _CookingStepsPageState();
}

class _CookingStepsPageState extends State<CookingStepsPage> {
  late List<bool> stepChecked;
  int currentStep = 0;
  bool isUpdatingPreferences = false;

  @override
  void initState() {
    super.initState();
    // Filter out empty or whitespace-only steps
    final filteredSteps = widget.steps.where((s) => s.trim().isNotEmpty).toList();
    stepChecked = List.filled(filteredSteps.length, false);
  }

  Future<void> _updateUserPreferences() async {
    if (isUpdatingPreferences) return;
    
    setState(() {
      isUpdatingPreferences = true;
    });

    try {
      final userId = UserSession().getUserId();
      if (userId == null || userId.isEmpty) {
        return;
      }

      final url = Uri.parse('${AppConfig.apiBaseUrl}/user/preferences/update-on-cook');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'recipe_name': widget.recipeName,
          'ingredients': widget.ingredients,
          'meal_type': widget.mealType,
          'cooking_time': widget.timeTaken,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Cooking completed! Your preferences have been updated.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Cooking completed, but preference update failed.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Cooking completed, but preference update failed.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUpdatingPreferences = false;
        });
      }
    }
  }

  Future<void> _finishCooking() async {
    // Update preferences first
    await _updateUserPreferences();
    
    // Then navigate to navbar
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Navbar()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter out empty or whitespace-only steps for display
    final filteredSteps = widget.steps.where((s) => s.trim().isNotEmpty).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F3354), Color(0xFF3E5879)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://raw.githubusercontent.com/Nayera-Mohamed-Hassen/LILI-/main/FoodImages/${Uri.encodeComponent(widget.image)}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Let\'s Start Cooking!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.recipeName,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicator
                    LinearProgressIndicator(
                      value: stepChecked.where((checked) => checked).length / filteredSteps.length,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      color: Colors.white.withOpacity(0.9),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${stepChecked.where((checked) => checked).length}/${filteredSteps.length} steps completed',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Steps list
                    ...filteredSteps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      final isChecked = stepChecked[index];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 0,
                        color: Colors.white.withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isChecked ? Colors.green.withOpacity(0.7) : Colors.white24,
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              stepChecked[index] = !stepChecked[index];
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isChecked ? Colors.green.withOpacity(0.7) : Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isChecked ? Colors.green.withOpacity(0.7) : Colors.white24,
                                    ),
                                  ),
                                  child: Center(
                                    child: isChecked
                                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                                        : Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    step,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isChecked ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.9),
                                      decoration: isChecked ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F3354),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isUpdatingPreferences ? null : _finishCooking,
            child: isUpdatingPreferences
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Finish Cooking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
