import 'package:flutter/material.dart';
import 'package:LILI/models/recipeItem.dart';
import 'wave2.dart';

class FavoritesPage extends StatelessWidget {
  final List<RecipeItem> allRecipes;
  final Set<RecipeItem> favoriteRecipes;
  final Function(RecipeItem) onFavoriteToggle;
  final bool isLoading;

  const FavoritesPage({
    Key? key,
    required this.allRecipes,
    required this.favoriteRecipes,
    required this.onFavoriteToggle,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoriteRecipeItems = favoriteRecipes.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Recipes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF1F3354),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F3354), Color(0xFF3E5879)],
          ),
        ),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : favoriteRecipeItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No favorite recipes yet.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoriteRecipeItems.length,
                    itemBuilder: (context, index) {
                      final recipe = favoriteRecipeItems[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipePage(
                                recipe: {
                                  'name': recipe.name,
                                  'cusine': recipe.cusine,
                                  'mealType': recipe.mealType,
                                  'ingredients': recipe.ingredients.toList(),
                                  'available_ingredients': recipe.availableIngredients.toList(),
                                  'missing_ingredients': recipe.missingIngredients.toList(),
                                  'steps': recipe.steps?.toList() ?? [],
                                  'timeTaken': recipe.timeTaken,
                                  'difficulty': recipe.difficulty,
                                  'image': recipe.image,
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.2),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.white.withOpacity(0.15),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Image.network(
                                          'https://raw.githubusercontent.com/Nayera-Mohamed-Hassen/LILI-/main/FoodImages/${Uri.encodeComponent(recipe.image)}',
                                          width: 100,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Container(
                                                width: 100,
                                                height: 110,
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Colors.white.withOpacity(0.7),
                                                ),
                                              ),
                                        ),
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
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            recipe.cusine,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: Colors.white.withOpacity(0.8),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            recipe.mealType,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              color: Colors.white.withOpacity(0.8),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: Colors.white.withOpacity(0.7),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                recipe.timeTaken,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 24,
                                      ),
                                      onPressed: () => onFavoriteToggle(recipe),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Ingredients Coverage: ${recipe.ingredientsCoverage}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1F3354),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white24),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          recipe.difficulty,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
