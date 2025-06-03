import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:LILI/models/recipeItem.dart';
import 'package:http/http.dart' as http;
import 'package:LILI/user_session.dart';

Future<List<RecipeItem>> fetchRecipes(int page) async {
  print('Fetching recipes for page: $page'); // Debug print
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8000/user/recipes'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': UserSession().getUserId(),
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

  const Recipe({
    Key? key,
    required this.favoriteRecipes,
    required this.onFavoriteToggle,
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
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
      final uniqueNewRecipes = newRecipes.where((r) => !existingNames.contains(r.name)).toList();
      
      print('Received ${uniqueNewRecipes.length} new unique recipes'); // Debug print
      
      setState(() {
        _allRecipes.addAll(uniqueNewRecipes);
        _isLoading = false;
        _hasMore = uniqueNewRecipes.length >= 10;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Recipe Suggestion',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F3354),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
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
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterBottomSheet,
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading && _allRecipes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filteredRecipes.isEmpty
                    ? const Center(child: Text('No recipes found'))
                    : ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredRecipes.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= filteredRecipes.length) {
                          return _buildLoadMoreButton();
                        }

                        final recipe = filteredRecipes[index];
                        return _buildRecipeCard(recipe);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3354),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _loadMoreRecipes,
                  child: const Text("Load More"),
                ),
      ),
    );
  }

  Widget _buildRecipeCard(RecipeItem recipe) {
    final isFavorite = widget.favoriteRecipes.contains(recipe);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF1F3354), width: 1),
      ),
      elevation: 8,
      shadowColor: const Color(0xFF1F3354),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    'https://raw.githubusercontent.com/Nayera-Mohamed-Hassen/LILI-/main/FoodImages/${Uri.encodeComponent(recipe.image)}',
                    width: 100,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
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
                      const SizedBox(height: 4),
                      Text(
                        recipe.cusine,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF1F3354),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Color(0xFF1F3354),
                          ),
                          const SizedBox(width: 4),
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
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () => widget.onFavoriteToggle(recipe),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F3354).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 16,
                        color: Color(0xFF1F3354),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Difficulty:',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF1F3354).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F3354),
                      borderRadius: BorderRadius.circular(12),
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
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
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
                              icon: const Icon(
                                Icons.clear,
                                color: Color(0xFFbc2c2c),
                              ),
                              label: const Text(
                                "Clear Filters",
                                style: TextStyle(color: Color(0xFFbc2c2c)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
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
                                      style: const TextStyle(
                                        color: Colors.white,
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
                                    backgroundColor: const Color(0xFF3E5879),
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
