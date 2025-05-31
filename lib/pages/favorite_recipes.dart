import 'package:flutter/material.dart';
import 'package:LILI/models/recipeItem.dart';

class FavoritesPage extends StatelessWidget {
  final List<RecipeItem> allRecipes;
  final Set<RecipeItem> favoriteRecipes;
  final Function(RecipeItem) onFavoriteToggle;

  const FavoritesPage({
    Key? key,
    required this.allRecipes,
    required this.favoriteRecipes,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoriteRecipeItems = favoriteRecipes.toList();

    print(favoriteRecipes.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Recipes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F3354),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body:
          favoriteRecipeItems.isEmpty
              ? const Center(
                child: Text(
                  "No favorite recipes yet.",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: favoriteRecipeItems.length,
                itemBuilder: (context, index) {
                  final recipe = favoriteRecipeItems[index];
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
                            child: Image.network(
                              'https://raw.githubusercontent.com/Nayera-Mohamed-Hassen/LILI-/main/FoodImages/${Uri.encodeComponent(recipe.image)}',
                              width: 100,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
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
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF1F3354),
                                  ),
                                ),
                                Text(
                                  recipe.cusine,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
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
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 28,
                                ),
                                onPressed: () => onFavoriteToggle(recipe),
                              ),
                              Text(
                                recipe.timeTaken,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xFF1F3354),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
