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
  final Map<String, dynamic> recipe;

  const RecipePage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> ingredients = List<String>.from(recipe['ingredients'] ?? []);
    final List<String> availableIngredients = List<String>.from(recipe['available_ingredients'] ?? []);
    final List<String> missingIngredients = List<String>.from(recipe['missing_ingredients'] ?? []);
    final List<String> steps = List<String>.from(recipe['steps'] ?? []);
    final String timeTaken = recipe['timeTaken'] as String;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF1F3354),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://raw.githubusercontent.com/Nayera-Mohamed-Hassen/LILI-/main/FoodImages/${Uri.encodeComponent(recipe['image'])}',
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
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['name'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                recipe['cusine'] as String,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                recipe['mealType'] as String,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
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
                  // Recipe Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(Icons.timer, color: Color(0xFF1F3354)),
                                const SizedBox(height: 8),
                                Text(
                                  timeTaken,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('Time'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.restaurant_menu,
                                  color: Color(0xFF1F3354),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  recipe['difficulty'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('Difficulty'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Ingredients Section
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3354),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // All Ingredients List
                  ...ingredients.map((ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          availableIngredients.contains(ingredient) 
                              ? Icons.check_circle 
                              : Icons.shopping_cart,
                          color: availableIngredients.contains(ingredient)
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ingredient,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 24),

                  // Steps Section
                  const Text(
                    'Cooking Steps',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3354),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...steps.asMap().entries.map(
                    (entry) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F3354),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1F3354),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CookingStepsPage(
                  image: recipe['image'] as String,
                  steps: steps,
                ),
              ),
            );
          },
          child: const Text(
            'Start Cooking',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

void main() => runApp(
  MaterialApp(
    home: RecipePage(
      recipe: {
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
        'timeTaken': '25 minutes',
      'difficulty': 'Medium',
        'image': 'Pad Thai.jpg',
        'available_ingredients': [
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
        'missing_ingredients': [],
      },
                        ),
                  ),
                );
