import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'recipes.dart';
import 'favorite_recipes.dart';
import 'myRecipes.dart';
import 'package:LILI/models/recipeItem.dart';
import 'package:LILI/services/favorite_service.dart';

class RecipeNavbar extends StatefulWidget {
  @override
  _RecipeNavbarState createState() => _RecipeNavbarState();
}

class _RecipeNavbarState extends State<RecipeNavbar> {
  int _pageIndex = 0;

  // Your favorite recipes set
  Set<RecipeItem> favoriteRecipes = {};
  List<RecipeItem> allRecipes = [];
  bool _isLoadingFavorites = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteRecipes();
  }

  Future<void> _loadFavoriteRecipes() async {
    setState(() {
      _isLoadingFavorites = true;
    });

    try {
      final favorites = await FavoriteService.getFavoriteRecipes();
      setState(() {
        favoriteRecipes = favorites.toSet();
        _isLoadingFavorites = false;
      });
    } catch (e) {
      print('Error loading favorite recipes: $e');
      setState(() {
        _isLoadingFavorites = false;
      });
    }
  }

  Future<void> toggleFavorite(RecipeItem recipe) async {
    try {
      final success = await FavoriteService.toggleFavorite(recipe);
      if (success) {
        setState(() {
          if (favoriteRecipes.contains(recipe)) {
            favoriteRecipes.remove(recipe);
          } else {
            favoriteRecipes.add(recipe);
          }
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorite status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Recipe(
        favoriteRecipes: favoriteRecipes,
        onFavoriteToggle: toggleFavorite,
        onRecipesLoaded: (recipes) {
          setState(() {
            allRecipes = recipes;
          });
        },
      ),
      FavoritesPage(
        allRecipes: allRecipes,
        favoriteRecipes: favoriteRecipes,
        onFavoriteToggle: toggleFavorite,
        isLoading: _isLoadingFavorites,
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
        backgroundColor: Color(0xFF3E5879),
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
