import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:LILI/models/recipeItem.dart';
import 'package:http/http.dart' as http;
import 'package:LILI/user_session.dart';
import 'wave2.dart';

Future<List<RecipeItem>> fetchRecipes(int page) async {
  final userId = UserSession().getUserId();
  if (userId == null || userId.isEmpty) {
    throw Exception('User ID is missing. Please log in again.');
  }
  print('Fetching recipes for page: $page'); // Debug print
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8000/user/recipes'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': userId,
      'recipeCount': page,
    }),
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    print('Received ${jsonList.length} recipes'); // Debug print
    if (jsonList.isNotEmpty) {
      print('First recipe: ${jsonList.first}'); // Debug print
    }
    return jsonList.map((json) => RecipeItem.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load recipes: ${response.statusCode}');
  }
}

class Recipe extends StatefulWidget {
  final Set<RecipeItem> favoriteRecipes;
  final Function(RecipeItem) onFavoriteToggle;
  final Function(List<RecipeItem>)? onRecipesLoaded;

  const Recipe({
    Key? key,
    required this.favoriteRecipes,
    required this.onFavoriteToggle,
    this.onRecipesLoaded,
  }) : super(key: key);

  @override
  State<Recipe> createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  List<RecipeItem> _allRecipes = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Set<String> selectedSubFilters = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentPage = 1;
    _loadInitialRecipes();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialRecipes() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      final recipes = await fetchRecipes(_currentPage);
      setState(() {
        _allRecipes = recipes;
        _isLoading = false;
        _hasMore = recipes.length >= 10;
      });
      if (widget.onRecipesLoaded != null) {
        widget.onRecipesLoaded!(_allRecipes);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _loadMoreRecipes() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    try {
      _currentPage++;
      print('Loading more recipes, page: $_currentPage'); // Debug print
      final newRecipes = await fetchRecipes(_currentPage);

      // Remove duplicates based on recipe name
      final existingNames = _allRecipes.map((r) => r.name).toSet();
      final uniqueNewRecipes =
          newRecipes.where((r) => !existingNames.contains(r.name)).toList();

      print(
        'Received ${uniqueNewRecipes.length} new unique recipes',
      ); // Debug print

      setState(() {
        _allRecipes.addAll(uniqueNewRecipes);
        _isLoading = false;
        _hasMore = uniqueNewRecipes.length >= 10;
      });
      if (widget.onRecipesLoaded != null) {
        widget.onRecipesLoaded!(_allRecipes);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    const threshold = 200.0; // Load more when within 200 pixels of the bottom

    if (maxScroll - currentScroll <= threshold) {
      _loadMoreRecipes();
    }
  }

  List<RecipeItem> filterRecipes(List<RecipeItem> recipes) {
    return recipes.where((recipe) {
      bool matches = true;

      if (selectedSubFilters.isNotEmpty) {
        // Filter by Cuisine
        if (filterOptions['Cuisine']!.any(selectedSubFilters.contains)) {
          matches &= selectedSubFilters.contains(recipe.cusine);
        }

        // Filter by Meal Type
        if (filterOptions['Meal Type']!.any(selectedSubFilters.contains)) {
          matches &= selectedSubFilters.contains(recipe.mealType);
        }

        // Filter by Difficulty
        if (filterOptions['Difficulty']!.any(selectedSubFilters.contains)) {
          matches &= selectedSubFilters.contains(recipe.difficulty);
        }

        // Filter by Duration
        if (filterOptions['Duration']!.any(selectedSubFilters.contains)) {
          bool durationMatch = false;
          final timeString = recipe.timeTaken.toLowerCase();

          // Check for "min" or "mins" in the time string
          if (timeString.contains('min')) {
            // Extract the numeric value
            final timeValue =
                int.tryParse(timeString.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

            if (selectedSubFilters.contains('Under 30 mins') &&
                recipe.timeTaken == "Under 30 mins") {
              durationMatch = true;
            } else if (selectedSubFilters.contains('30-60 mins') &&
                recipe.timeTaken == "30-60 mins") {
              durationMatch = true;
            } else if (selectedSubFilters.contains('Over 60 mins') &&
                recipe.timeTaken == "Over 60 mins") {
              durationMatch = true;
            }
          }
          matches &= durationMatch;
        }
      }

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        final nameMatch = recipe.name.toLowerCase().contains(lowerQuery);
        final ingredientsMatch = recipe.ingredients.any(
          (ingredient) => ingredient.toLowerCase().contains(lowerQuery),
        );
        matches &= (nameMatch || ingredientsMatch);
      }

      return matches;
    }).toList();
  }

  final Map<String, List<String>> filterOptions = {
    'Cuisine': [
      'Italian',
      'Chinese',
      'Indian',
      'French',
      'Middle Eastern',
      'Mexican',
      'Japanese',
      'Greek',
      'Thai',
      'Spanish',
      'American',
    ],
    'Meal Type': [
      'Breakfast',
      'Lunch',
      'Dinner',
      'Snack',
      'Brunch',
      'Dessert',
      'Appetizer',
      'Side Dish',
      'Beverage',
      'Salad',
    ],
    'Difficulty': [
      'Quick & Easy (under 30 mins)',
      'Intermediate',
      'Advanced/Gourmet',
      '5-Ingredient Recipes',
      'Beginner-Friendly',
      'One-Pot Meals',
      'Family-Friendly',
      'Meal Prep',
      'Budget-Friendly',
      'Low Effort',
    ],
    'Duration': ['Under 30 mins', '30-60 mins', 'Over 60 mins'],
  };

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = filterRecipes(_allRecipes);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1F3354), const Color(0xFF3E5879)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  'Recipes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildSearch(),
              //_buildFilterChips(),
              Expanded(
                child: filteredRecipes.isEmpty && _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.white))
                    : _buildRecipeList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged:
                    (value) =>
                        setState(() => searchQuery = value.toLowerCase()),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: Colors.white38),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: Colors.white.withOpacity(0.9),
              ),
              onPressed: _showFilterBottomSheet,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildFilterChips() {
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Wrap(
  //       spacing: 6,
  //       runSpacing: 6,
  //       children:
  //           filterOptions.entries.map((category) {
  //             return FilterChip(
  //               label: Text(
  //                 category.key,
  //                 style: const TextStyle(color: Colors.white),
  //               ),
  //               selected: selectedSubFilters.contains(category.value.first),
  //               onSelected: (selected) {
  //                 setState(() {
  //                   if (selected) {
  //                     selectedSubFilters.add(category.value.first);
  //                   } else {
  //                     selectedSubFilters.remove(category.value.first);
  //                   }
  //                 });
  //               },
  //               selectedColor: const Color(0xFF1F3354),
  //               backgroundColor: Colors.white.withOpacity(0.15),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //                 side: BorderSide(
  //                   color:
  //                       selectedSubFilters.contains(category.value.first)
  //                           ? Colors.white38
  //                           : Colors.white24,
  //                 ),
  //               ),
  //               showCheckmark: false,
  //             );
  //           }).toList(),
  //     ),
  //   );
  // }

  Widget _buildRecipeList() {
    final filteredRecipes = filterRecipes(_allRecipes);

    if (filteredRecipes.isEmpty) {
      return Center(
        child: Text(
          'No recipes found',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey('recipeList'),
      controller: _scrollController,
      itemCount: filteredRecipes.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= filteredRecipes.length) {
          return _buildLoadMoreButton();
        }
        final recipe = filteredRecipes[index];
        return _buildRecipeCard(recipe);
      },
    );
  }

  Widget _buildLoadMoreButton() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: TextButton.icon(
        onPressed: _loadMoreRecipes,
        icon: Icon(
          Icons.refresh,
          color: Colors.white.withOpacity(0.9),
        ),
        label: Text(
          "Load More",
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(RecipeItem recipe) {
    final isFavorite = widget.favoriteRecipes.contains(recipe);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => RecipePage(
                  recipe: {
                    'name': recipe.name,
                    'cusine': recipe.cusine,
                    'mealType': recipe.mealType,
                    'ingredients': recipe.ingredients.toList(),
                    'available_ingredients':
                        recipe.availableIngredients.toList(),
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
          side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Colors.white.withOpacity(0.15),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
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
                        errorBuilder:
                            (context, error, stackTrace) => Container(
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    recipe.timeTaken,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.8),
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
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color:
                          isFavorite
                              ? Colors.red
                              : Colors.white.withOpacity(0.7),
                      size: 24,
                    ),
                    onPressed: () => widget.onFavoriteToggle(recipe),
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
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Difficulty:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
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
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1F3354), Color(0xFF3E5879)],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() => selectedSubFilters.clear());
                                setModalState(() {});
                              },
                              icon: Icon(
                                Icons.clear,
                                color: Colors.red.shade400,
                              ),
                              label: Text(
                                "Clear Filters",
                                style: TextStyle(color: Colors.red.shade400),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        for (var category in filterOptions.entries) ...[
                          Text(
                            category.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children:
                                category.value.map((subFilter) {
                                  final isSelected = selectedSubFilters
                                      .contains(subFilter);
                                  return FilterChip(
                                    label: Text(
                                      subFilter,
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Color(
                                                  0xFF1F3354,
                                                ).withOpacity(0.9),
                                      ),
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setModalState(() {
                                        if (selected) {
                                          selectedSubFilters.add(subFilter);
                                        } else {
                                          selectedSubFilters.remove(subFilter);
                                        }
                                      });
                                      setState(() {});
                                    },
                                    selectedColor: const Color(0xFF1F3354),
                                    backgroundColor: Colors.white.withOpacity(
                                      0.15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color:
                                            isSelected
                                                ? Colors.white38
                                                : Colors.white24,
                                      ),
                                    ),
                                    showCheckmark: false,
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
