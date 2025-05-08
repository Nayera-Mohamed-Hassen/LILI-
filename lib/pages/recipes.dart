import 'package:flutter/material.dart';

class RecipeItem {
  final String name;
  final String cusine;
  final String mealType;
  final List<String> ingredients;
  final Duration timeTaken;
  final String difficulty;
  final String image;

  RecipeItem({
    required this.name,
    required this.cusine,
    required this.mealType,
    required this.ingredients,
    required this.timeTaken,
    required this.difficulty,
    required this.image,
  });
}

class Recipe extends StatefulWidget {
  const Recipe({super.key});

  @override
  State<Recipe> createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  Set<String> selectedSubFilters = {};

  final List<RecipeItem> recipes = [
    RecipeItem(
      name: 'Spaghetti Carbonara',
      cusine: 'Italian',
      mealType: 'Dinner',
      ingredients: ['Spaghetti', 'Eggs', 'Parmesan cheese', 'Bacon'],
      timeTaken: Duration(minutes: 30),
      difficulty: 'Intermediate',
      image: 'assets/recipes/Spaghetti Carbonara.jpg',
    ),
    RecipeItem(
      name: 'Sushi Rolls',
      cusine: 'Japanese',
      mealType: 'Dinner',
      ingredients: ['Sushi rice', 'Nori', 'Salmon', 'Avocado', 'Soy sauce'],
      timeTaken: Duration(minutes: 45),
      difficulty: 'Advanced/Gourmet',
      image: 'assets/recipes/Sushi Rolls.jpg',
    ),
    RecipeItem(
      name: 'Tacos',
      cusine: 'Mexican',
      mealType: 'Lunch',
      ingredients: [
        'Taco shells',
        'Ground beef',
        'Lettuce',
        'Cheese',
        'Sour cream',
      ],
      timeTaken: Duration(minutes: 25),
      difficulty: 'Quick & Easy (under 30 mins)',
      image: 'assets/recipes/tacos.jpg',
    ),
    RecipeItem(
      name: 'Vegan Buddha Bowl',
      cusine: 'Vegan',
      mealType: 'Lunch',
      ingredients: ['Quinoa', 'Chickpeas', 'Avocado', 'Spinach', 'Tahini'],
      timeTaken: Duration(minutes: 30),
      difficulty: 'Intermediate',
      image: 'assets/recipes/Vegan Buddha Bowl.jpg',
    ),
    RecipeItem(
      name: 'Chicken Alfredo',
      cusine: 'Italian',
      mealType: 'Dinner',
      ingredients: [
        'Fettuccine',
        'Chicken breast',
        'Heavy cream',
        'Parmesan cheese',
        'Garlic',
      ],
      timeTaken: Duration(minutes: 40),
      difficulty: 'Intermediate',
      image: 'assets/recipes/Chicken Alfredo.jpg',
    ),
    RecipeItem(
      name: 'Pad Thai',
      cusine: 'Thai',
      mealType: 'Dinner',
      ingredients: ['Rice noodles', 'Shrimp', 'Egg', 'Peanuts', 'Bean sprouts'],
      timeTaken: Duration(minutes: 30),
      difficulty: 'Intermediate',
      image: 'assets/recipes/Pad Thai.jpg',
    ),
    RecipeItem(
      name: 'Beef Wellington',
      cusine: 'English',
      mealType: 'Dinner',
      ingredients: ['Beef tenderloin', 'Puff pastry', 'Mushrooms', 'Egg yolk'],
      timeTaken: Duration(minutes: 120),
      difficulty: 'Advanced/Gourmet',
      image: 'assets/recipes/Beef Wellington.jpg',
    ),
    RecipeItem(
      name: 'Falafel',
      cusine: 'Middle Eastern',
      mealType: 'Lunch',
      ingredients: ['Chickpeas', 'Garlic', 'Cumin', 'Parsley', 'Tahini'],
      timeTaken: Duration(minutes: 45),
      difficulty: 'Intermediate',
      image: 'assets/recipes/Falafel.jpg',
    ),
    RecipeItem(
      name: 'Fish Tacos',
      cusine: 'Mexican',
      mealType: 'Lunch',
      ingredients: [
        'Fish fillets',
        'Taco shells',
        'Cabbage',
        'Lime',
        'Cilantro',
      ],
      timeTaken: Duration(minutes: 20),
      difficulty: 'Quick & Easy (under 30 mins)',
      image: 'assets/recipes/Fish Tacos.jpg',
    ),
    RecipeItem(
      name: 'Chicken Tikka Masala',
      cusine: 'Indian',
      mealType: 'Dinner',
      ingredients: [
        'Chicken',
        'Yogurt',
        'Tomato sauce',
        'Garam masala',
        'Cream',
      ],
      timeTaken: Duration(minutes: 60),
      difficulty: 'Intermediate',
      image: 'assets/recipes/Chicken Tikka Masala.jpg',
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    List<RecipeItem> filteredRecipes =
        recipes.where((recipe) {
          bool matches = true;

          // Filtering logic (unchanged)
          if (selectedSubFilters.isNotEmpty) {
            if (filterOptions['Cuisine']!.any(selectedSubFilters.contains)) {
              matches &= selectedSubFilters.contains(recipe.cusine);
            }

            if (filterOptions['Meal Type']!.any(selectedSubFilters.contains)) {
              matches &= selectedSubFilters.contains(recipe.mealType);
            }

            if (filterOptions['Difficulty']!.any(selectedSubFilters.contains)) {
              matches &= selectedSubFilters.contains(recipe.difficulty);
            }

            if (filterOptions['Duration']!.any(selectedSubFilters.contains)) {
              bool match = false;
              if (selectedSubFilters.contains('Under 30 mins') &&
                  recipe.timeTaken.inMinutes <= 30)
                match = true;
              if (selectedSubFilters.contains('30-60 mins') &&
                  recipe.timeTaken.inMinutes > 30 &&
                  recipe.timeTaken.inMinutes <= 60)
                match = true;
              if (selectedSubFilters.contains('Over 60 mins') &&
                  recipe.timeTaken.inMinutes > 60)
                match = true;
              matches &= match;
            }
          }

          // New: Search by name or ingredients
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Recommendation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F3354),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
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
                                        // Top row with Clear and Close buttons
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  selectedSubFilters.clear();
                                                });
                                                setModalState(() {});
                                              },
                                              icon: const Icon(
                                                Icons.clear,
                                                color: Colors.red,
                                              ),
                                              label: const Text(
                                                "Clear Filters",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed:
                                                  () => Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        ...filterOptions.entries.map((entry) {
                                          final category = entry.key;
                                          final options = entry.value;

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                category,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 4,
                                                children:
                                                    options.map((option) {
                                                      final isSelected =
                                                          selectedSubFilters
                                                              .contains(option);
                                                      return FilterChip(
                                                        backgroundColor:
                                                            const Color(
                                                              0xFF3E5879,
                                                            ),
                                                        selectedColor:
                                                            const Color(
                                                              0xFF1F3354,
                                                            ),
                                                        checkmarkColor:
                                                            Colors.white,
                                                        label: Text(
                                                          option,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                        ),
                                                        selected: isSelected,
                                                        onSelected: (selected) {
                                                          setState(() {
                                                            if (selected) {
                                                              selectedSubFilters
                                                                  .add(option);
                                                            } else {
                                                              selectedSubFilters
                                                                  .remove(
                                                                    option,
                                                                  );
                                                            }
                                                          });
                                                          setModalState(() {});
                                                        },
                                                      );
                                                    }).toList(),
                                              ),
                                              const SizedBox(height: 16),
                                            ],
                                          );
                                        }).toList(),
                                        Center(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF1F3354,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 32,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('Apply Filters'),
                                          ),
                                        ),
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

            // Recipe List
            Column(
              children:
                  filteredRecipes.map((recipe) {
                    return ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      title: Text(recipe.name),
                      subtitle: Text(
                        '${recipe.cusine} - ${recipe.mealType} - ${recipe.difficulty}',
                      ),
                      leading: SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.asset(recipe.image, fit: BoxFit.cover),
                      ),
                      trailing: Text('${recipe.timeTaken.inMinutes} min'),
                      onTap: () {
                        // Handle tap
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
