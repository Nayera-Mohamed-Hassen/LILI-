import 'package:flutter/material.dart';
import 'CookingStepsPage.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double waveHeight = size.height * 0.6;

    path.moveTo(-100, size.height / 1.5);
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height / 4 + waveHeight,
      size.width * 0.23,
      size.height / 1.8,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height / 1.7 - waveHeight,
      size.width * 0.77,
      size.height / 1.8,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height / 4 + waveHeight,
      size.width + 100,
      size.height / 1.5,
    );

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RecipePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, Object> recipe = {
      'name': 'Pad Thai',
      'cusine': 'Thai',
      'mealType': 'Main Course',
      'ingredients': [
        '200g rice noodles',
        '150g chicken breast (or shrimp)',
        '1 egg',
        '2 tbsp soy sauce',
        '1 tbsp fish sauce',
        '1 tsp sugar',
        '1/4 cup chopped peanuts',
        '1 lime (cut into wedges)',
        'Fresh cilantro (chopped)',
        '2 tbsp vegetable oil',
        '1 garlic clove (minced)',
        '1/4 cup bean sprouts',
        '1/4 cup green onions (chopped)',
      ],
      'steps': [
        'Boil the rice noodles according to the package instructions.',
        'In a pan, cook chicken until golden.',
        'Add egg, scramble, then mix with meat.',
        'Add garlic and stir until fragrant.',
        'Add cooked noodles, sauces, and sugar. Mix well.',
        'Stir in peanuts, green onions, and sprouts.',
        'Serve garnished with cilantro and lime wedges.',
      ],
      'timeTaken': Duration(minutes: 25),
      'difficulty': 'Medium',
      'image': 'assets/recipes/Pad Thai.jpg',
    };

    final List<String> ingredients = recipe['ingredients'] as List<String>;
    final List<String> steps = recipe['steps'] as List<String>;
    final Duration timeTaken = recipe['timeTaken'] as Duration;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F3354),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Recipe Page', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(height: 200, color: const Color(0xFF1F3354)),
              ),
              Column(
                children: [
                  SizedBox(height: 80),
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        recipe['image'] as String,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['name'] as String,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${recipe['cusine']} | ${recipe['mealType']}',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Difficulty: ${recipe['difficulty']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Time: ${timeTaken.inMinutes} minutes',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...ingredients.map((ingredient) => Text('- $ingredient')),
                  const SizedBox(height: 20),
                  const Text(
                    'Steps',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...steps.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('${entry.key + 1}. ${entry.value}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F3354),
                padding: const EdgeInsets.symmetric(
                  horizontal: 52,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CookingStepsPage(
                          image: recipe['image'] as String,
                          steps: steps,
                        ),
                  ),
                );
              },
              child: const Text(
                'Start Cooking',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: RecipePage()));
