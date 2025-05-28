import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:LILI/models/recipeItem.dart';
import 'package:http/http.dart' as http;

Future<List<RecipeItem>> fetchRecipes() async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8000/user/recipes'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({}), // Sending an empty JSON body
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
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
  late Future<List<RecipeItem>> futureRecipes;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Set<String> selectedSubFilters = {};

  @override
  void initState() {
    super.initState();
    futureRecipes = fetchRecipes();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
    'Diet': [
      'Vegan',
      'Vegetarian',
      'Keto',
      'Gluten-Free',
      'Paleo',
      'Low-Carb',
      'Dairy-Free',
      'Low-Fat',
      'Whole30',
      'Halal',
    ],
    'Duration': ['Under 30 mins', '30-60 mins', 'Over 60 mins'],
  };

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
          bool match = false;
          if (selectedSubFilters.contains('Under 30 mins') &&
              recipe.timeTaken <= Duration(minutes: 30)) {
            match = true;
          }
          if (selectedSubFilters.contains('30-60 mins') &&
              recipe.timeTaken > Duration(minutes: 30) &&
              recipe.timeTaken <= Duration(minutes: 60)) {
            match = true;
          }
          if (selectedSubFilters.contains('Over 60 mins') &&
              recipe.timeTaken > Duration(minutes: 60)) {
            match = true;
          }
          matches &= match;
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

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 3),
                  Row(
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
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value.toLowerCase();
                              });
                            },
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
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (BuildContext context) {
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  TextButton.icon(
                                                    onPressed: () {
                                                      setState(() {
                                                        selectedSubFilters
                                                            .clear();
                                                      });
                                                      setModalState(() {});
                                                    },
                                                    icon: const Icon(
                                                      Icons.clear,
                                                      color: Color(0xFFbc2c2c),
                                                    ),
                                                    label: const Text(
                                                      "Clear Filters",
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFFbc2c2c,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.close,
                                                    ),
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              for (var category
                                                  in filterOptions.entries) ...[
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
                                                      category.value.map((
                                                        subFilter,
                                                      ) {
                                                        final isSelected =
                                                            selectedSubFilters
                                                                .contains(
                                                                  subFilter,
                                                                );
                                                        return FilterChip(
                                                          label: Text(
                                                            subFilter,
                                                            style:
                                                                const TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                          ),
                                                          selected: isSelected,
                                                          onSelected: (
                                                            selected,
                                                          ) {
                                                            setModalState(() {
                                                              if (selected) {
                                                                selectedSubFilters
                                                                    .add(
                                                                      subFilter,
                                                                    );
                                                              } else {
                                                                selectedSubFilters
                                                                    .remove(
                                                                      subFilter,
                                                                    );
                                                              }
                                                            });
                                                            setState(() {});
                                                          },
                                                          selectedColor:
                                                              const Color(
                                                                0xFF1F3354,
                                                              ),
                                                          backgroundColor:
                                                              const Color(
                                                                0xFF3E5879,
                                                              ),
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
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<RecipeItem>>(
                    future: futureRecipes,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No recipes found'));
                      } else {
                        final filteredRecipes = filterRecipes(snapshot.data!);

                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = filteredRecipes[index];
                            final isFavorite = widget.favoriteRecipes.contains(
                              recipe,
                            );

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
                                        recipe.image,
                                        width: 100,
                                        height: 110,
                                        fit: BoxFit.cover,
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
                                          IconButton(
                                            iconSize: 28,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color:
                                                  isFavorite
                                                      ? Colors.red
                                                      : const Color(0xFF1F3354),
                                            ),
                                            onPressed: () {
                                              widget.onFavoriteToggle(recipe);
                                            },
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${recipe.timeTaken.inMinutes} min',
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
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
