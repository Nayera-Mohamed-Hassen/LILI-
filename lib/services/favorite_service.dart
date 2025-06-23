import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipeItem.dart';
import '../user_session.dart';

class FavoriteService {
  static const String baseUrl = 'http://10.0.2.2:8000/user';

  // Add a recipe to favorites
  static Future<bool> addToFavorites(RecipeItem recipe) async {
    try {
      final userId = UserSession().getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID is missing. Please log in again.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/favorites/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'recipe': recipe.toJson(),
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 400) {
        // Recipe is already in favorites
        return true;
      } else {
        throw Exception('Failed to add to favorites: ${response.statusCode}');
      }
    } catch (e) {
      return false;
    }
  }

  // Remove a recipe from favorites
  static Future<bool> removeFromFavorites(RecipeItem recipe) async {
    try {
      final userId = UserSession().getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID is missing. Please log in again.');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/remove'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'recipe_name': recipe.name,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        // Recipe not found in favorites (already removed)
        return true;
      } else {
        throw Exception('Failed to remove from favorites: ${response.statusCode}');
      }
    } catch (e) {
      return false;
    }
  }

  // Get all favorite recipes for a user
  static Future<List<RecipeItem>> getFavoriteRecipes() async {
    try {
      final userId = UserSession().getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID is missing. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/favorites/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => RecipeItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load favorite recipes: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  // Check if a recipe is in favorites
  static Future<bool> isFavorite(RecipeItem recipe) async {
    try {
      final userId = UserSession().getUserId();
      if (userId == null || userId.isEmpty) {
        return false;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/favorites/$userId/check/${Uri.encodeComponent(recipe.name)}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        return result['is_favorite'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Toggle favorite status
  static Future<bool> toggleFavorite(RecipeItem recipe) async {
    try {
      final isCurrentlyFavorite = await isFavorite(recipe);
      
      if (isCurrentlyFavorite) {
        return await removeFromFavorites(recipe);
      } else {
        return await addToFavorites(recipe);
      }
    } catch (e) {
      return false;
    }
  }
} 