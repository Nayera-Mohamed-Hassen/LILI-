import 'package:flutter/material.dart';
import 'addRecipe.dart'; // your add recipe screen import
import '../models/recipeItem.dart'; // your RecipeItem model import
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../user_session.dart';

class MyRecipesPage extends StatefulWidget {
  const MyRecipesPage({Key? key}) : super(key: key);

  @override
  _MyRecipesPageState createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {
  List<RecipeItem> _recipes = [];
  List<RecipeItem> _householdRecipes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _fetchHouseholdRecipes();
  }

  Future<void> _fetchRecipes() async {
    setState(() => _isLoading = true);
    final userId = UserSession().getUserId();
    if (userId == null || userId.isEmpty) {
      setState(() {
        _recipes = [];
        _isLoading = false;
      });
      return;
    }
    final url = Uri.parse('http://10.0.2.2:8000/user/recipes/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _recipes = data.map((json) => RecipeItem.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _recipes = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchHouseholdRecipes() async {
    final userId = UserSession().getUserId();
    if (userId == null || userId.isEmpty) {
      setState(() {
        _householdRecipes = [];
      });
      return;
    }
    final url = Uri.parse(
      'http://10.0.2.2:8000/user/recipes/$userId?shared=true',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        // Exclude the current user's own recipes
        _householdRecipes =
            data
                .map((json) => RecipeItem.fromJson(json))
                .where(
                  (r) => r.id == null || !_recipes.any((my) => my.id == r.id),
                )
                .toList();
      });
    } else {
      setState(() {
        _householdRecipes = [];
      });
    }
  }

  Future<void> _navigateToAddRecipe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddRecipeScreen()),
    );

    if (result != null && result is RecipeItem) {
      await _saveRecipe(result, result.shared);
      _fetchRecipes();
      _fetchHouseholdRecipes();
    }
  }

  Future<void> _saveRecipe(RecipeItem recipe, bool shared) async {
    final userId = UserSession().getUserId();
    if (userId == null || userId.isEmpty) return;
    final url = Uri.parse('http://10.0.2.2:8000/user/recipes/save');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'recipe': recipe.toJson(),
        'shared': shared,
      }),
    );
    // Optionally handle response
  }

  Future<void> _updateRecipeShared(String? recipeId, bool shared) async {
    if (recipeId == null) return;
    final url = Uri.parse('http://10.0.2.2:8000/user/recipes/update-shared');
    await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'recipe_id': recipeId, 'shared': shared}),
    );
    await _fetchRecipes();
    await _fetchHouseholdRecipes();
  }

  void _deleteRecipe(RecipeItem recipe) {
    setState(() {
      _recipes.remove(recipe);
    });
    // Optionally: Add backend delete logic
  }

  void _editRecipe(RecipeItem recipe) {
    // TODO: Implement edit recipe functionality
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F3354), Color(0xFF3E5879)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'My Recipes',
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
          actions: [],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // Main content
              Positioned.fill(
                child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_recipes.isEmpty)
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.menu_book,
                                        size: 64,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "You haven't created any recipes yet.",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton.icon(
                                        onPressed: _navigateToAddRecipe,
                                        icon: const Icon(Icons.add),
                                        label: const Text('Create Recipe'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white.withOpacity(
                                            0.15,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            side: BorderSide(color: Colors.white24),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _recipes.length,
                                  itemBuilder: (context, index) {
                                    final recipe = _recipes[index];
                                    return Card(
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(
                                                    16,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.2),
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
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => Container(
                                                            width: 100,
                                                            height: 110,
                                                            decoration: BoxDecoration(
                                                              color: Colors.white
                                                                  .withOpacity(0.1),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                            child: Icon(
                                                              Icons.broken_image,
                                                              color: Colors.white
                                                                  .withOpacity(0.7),
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
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
                                                          color: Colors.white
                                                              .withOpacity(0.8),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: Colors.white
                                                                  .withOpacity(0.15),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              border: Border.all(
                                                                color: Colors.white24,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .timer_outlined,
                                                                  size: 14,
                                                                  color: Colors.white
                                                                      .withOpacity(
                                                                        0.8,
                                                                      ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  recipe.timeTaken,
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize: 12,
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                          0.8,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(width: 12),
                                                          // Text(
                                                          //   recipe.shared ? 'Public' : 'Private',
                                                          //   style: TextStyle(
                                                          //     color: Colors.white70,
                                                          //   ),
                                                          // ),
                                                          // Switch(
                                                          //   value: recipe.shared,
                                                          //   onChanged: (val) async {
                                                          //     await _updateRecipeShared(
                                                          //       recipe.id,
                                                          //       val,
                                                          //     );
                                                          //     setState(() {
                                                          //       recipe.shared = val;
                                                          //     });
                                                          //   },
                                                          //   activeColor: Colors.white,
                                                          //   inactiveThumbColor: Colors.white24,
                                                          // ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuButton<String>(
                                                  icon: Icon(
                                                    Icons.more_vert,
                                                    color: Colors.white.withOpacity(
                                                      0.9,
                                                    ),
                                                  ),
                                                  color: const Color(0xFF1F3354),
                                                  itemBuilder:
                                                      (context) => [
                                                        PopupMenuItem(
                                                          value: 'edit',
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.edit,
                                                                size: 20,
                                                                color: Colors.white
                                                                    .withOpacity(0.9),
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                'Edit',
                                                                style: TextStyle(
                                                                  color: Colors.white
                                                                      .withOpacity(
                                                                        0.9,
                                                                      ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        PopupMenuItem(
                                                          value: 'delete',
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.delete,
                                                                size: 20,
                                                                color:
                                                                    Colors
                                                                        .red
                                                                        .shade300,
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                'Delete',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .red
                                                                          .shade300,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        PopupMenuItem(
                                                          value:
                                                              recipe.shared
                                                                  ? 'make_private'
                                                                  : 'make_public',
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                recipe.shared
                                                                    ? Icons.lock
                                                                    : Icons.public,
                                                                size: 20,
                                                                color: Colors.white
                                                                    .withOpacity(0.9),
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                recipe.shared
                                                                    ? 'Make Private'
                                                                    : 'Make Public',
                                                                style: TextStyle(
                                                                  color: Colors.white
                                                                      .withOpacity(
                                                                        0.9,
                                                                      ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                  onSelected: (value) async {
                                                    if (value == 'edit') {
                                                      _editRecipe(recipe);
                                                    } else if (value == 'delete') {
                                                      _deleteRecipe(recipe);
                                                    } else if (value ==
                                                            'make_private' ||
                                                        value == 'make_public') {
                                                      final newShared =
                                                          value == 'make_public';
                                                      await _updateRecipeShared(
                                                        recipe.id,
                                                        newShared,
                                                      );
                                                      setState(() {
                                                        recipe.shared = newShared;
                                                      });
                                                    }
                                                  },
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
                                                borderRadius: BorderRadius.circular(
                                                  12,
                                                ),
                                                border: Border.all(
                                                  color: Colors.white24,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.restaurant_menu,
                                                        size: 16,
                                                        color: Colors.white
                                                            .withOpacity(0.8),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Difficulty:',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white
                                                              .withOpacity(0.8),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF1F3354),
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: Colors.white24,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
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
                                    );
                                  },
                                ),
                              if (_householdRecipes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Household Shared Recipes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (_householdRecipes.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _householdRecipes.length,
                                  itemBuilder: (context, index) {
                                    final recipe = _householdRecipes[index];
                                    return Card(
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(
                                                    16,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.2),
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
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => Container(
                                                            width: 100,
                                                            height: 110,
                                                            decoration: BoxDecoration(
                                                              color: Colors.white
                                                                  .withOpacity(0.1),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                            child: Icon(
                                                              Icons.broken_image,
                                                              color: Colors.white
                                                                  .withOpacity(0.7),
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
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
                                                          color: Colors.white
                                                              .withOpacity(0.8),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: Colors.white
                                                                  .withOpacity(0.15),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              border: Border.all(
                                                                color: Colors.white24,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .timer_outlined,
                                                                  size: 14,
                                                                  color: Colors.white
                                                                      .withOpacity(
                                                                        0.8,
                                                                      ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  recipe.timeTaken,
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize: 12,
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                          0.8,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
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
                                                borderRadius: BorderRadius.circular(
                                                  12,
                                                ),
                                                border: Border.all(
                                                  color: Colors.white24,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.restaurant_menu,
                                                        size: 16,
                                                        color: Colors.white
                                                            .withOpacity(0.8),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Difficulty:',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white
                                                              .withOpacity(0.8),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF1F3354),
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: Colors.white24,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
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
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
              ),
              // Add button (bottom right, overlay, not in scroll)
              Positioned(
                bottom: 24,
                right: 24,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: _navigateToAddRecipe,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'Add Recipe',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
