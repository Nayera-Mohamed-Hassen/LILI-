import 'package:flutter/material.dart';
import 'addRecipe.dart'; // your add recipe screen import
import '../models/recipeItem.dart'; // your RecipeItem model import

class MyRecipesPage extends StatefulWidget {
  const MyRecipesPage({Key? key}) : super(key: key);

  @override
  _MyRecipesPageState createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {
  List<RecipeItem> _recipes = [];

  Future<void> _navigateToAddRecipe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddRecipeScreen()),
    );

    if (result != null && result is RecipeItem) {
      setState(() {
        _recipes.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('My Recipes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F3354),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          _recipes.isEmpty
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "You haven't added any recipes yet.",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _recipes.length,
                itemBuilder: (context, index) {
                  final recipe = _recipes[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(
                        color: Color(0xFF1F3354),
                        width: 1,
                      ),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF1F3354),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/recipes/Sushi Rolls.jpg',
                              width: 110, // fixed square width
                              height:
                                  110, // fixed square height (same as width)
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: Color(0xFF1F3354),
                                  ),
                                ),
                                Text(
                                  recipe.cusine,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF1F3354),
                                  ),
                                ),
                                Text(
                                  recipe.difficulty,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Color(0xFF1F3354),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 60,
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Removed favorite IconButton here
                                Text(
                                  recipe.timeTaken,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xFF1F3354),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          Positioned(
            left: MediaQuery.of(context).size.width - 90,
            bottom: 30,
            child: SizedBox(
              height: 70,
              width: 70,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1F3354),
                  iconColor: Colors.white,
                ),
                onPressed: _navigateToAddRecipe,
                child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _navigateToAddRecipe,
      //   backgroundColor: const Color(0xFF1F3354),
      //   foregroundColor: Color(0xFFf2f2f2),
      //   child: const Icon(Icons.add),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
    );
  }
}
