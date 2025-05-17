import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'recipes.dart';
import 'favorite_recipes.dart';
import 'myRecipes.dart';
import 'package:LILI/models/recipeItem.dart';

class RecipeNavbar extends StatefulWidget {
  @override
  _RecipeNavbarState createState() => _RecipeNavbarState();
}

class _RecipeNavbarState extends State<RecipeNavbar> {
  int _pageIndex = 0;

  // Your favorite recipes set
  Set<RecipeItem> favoriteRecipes = {};

  // Sample allRecipes list - replace with your actual data
  final List<RecipeItem> allRecipes = [];

  void toggleFavorite(RecipeItem recipe) {
    setState(() {
      if (favoriteRecipes.contains(recipe)) {
        favoriteRecipes.remove(recipe);
      } else {
        favoriteRecipes.add(recipe);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Recipe(
        favoriteRecipes: favoriteRecipes,
        onFavoriteToggle: toggleFavorite,
      ),
      FavoritesPage(
        allRecipes: allRecipes,
        favoriteRecipes: favoriteRecipes,
        onFavoriteToggle: toggleFavorite,
      ),
      MyRecipesPage(),
    ];

    return Scaffold(
      body: _pages[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex,
        height: 60.0,
        items: const [
          Icon(Icons.restaurant_menu, size: 30, color: Color(0xFFF2F2F2)),
          Icon(Icons.favorite, size: 30, color: Color(0xFFF2F2F2)),
          Icon(Icons.book, size: 30, color: Color(0xFFF2F2F2)),
        ],
        color: Color(0xFF1F3354),
        buttonBackgroundColor: Color(0xFF1F3354),
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}
