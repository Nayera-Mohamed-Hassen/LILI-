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
  String? selectedCategory;
  Set<String> selectedSubFilters = {};

  final List<RecipeItem> recipes = [
    RecipeItem(
      name: 'Spaghetti Carbonara',
      cusine: 'Italian',
      mealType: 'Dinner',
      ingredients: ['Spaghetti', 'Eggs', 'Parmesan cheese', 'Bacon'],
      timeTaken: Duration(minutes: 30),
      difficulty: 'Intermediate',
      image: 'assets/recipes/Spaghetti Carbonara.jpg'
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
      ingredients: ['Taco shells', 'Ground beef', 'Lettuce', 'Cheese', 'Sour cream'],
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
      ingredients: ['Fettuccine', 'Chicken breast', 'Heavy cream', 'Parmesan cheese', 'Garlic'],
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
      ingredients: ['Fish fillets', 'Taco shells', 'Cabbage', 'Lime', 'Cilantro'],
      timeTaken: Duration(minutes: 20),
      difficulty: 'Quick & Easy (under 30 mins)',
      image: 'assets/recipes/Fish Tacos.jpg',
    ),
    RecipeItem(
      name: 'Chicken Tikka Masala',
      cusine: 'Indian',
      mealType: 'Dinner',
      ingredients: ['Chicken', 'Yogurt', 'Tomato sauce', 'Garam masala', 'Cream'],
      timeTaken: Duration(minutes: 60),
      difficulty: 'Intermediate',
      image: 'assets/recipes/Chicken Tikka Masala.jpg',
    ),
  ];

  final Map<String, List<String>> filterOptions = {
    'Cuisine': ['Italian', 'Chinese', 'Indian', 'French','Middle Eastern', 'Mexican', 'Japanese', 'Greek', 'Thai', 'Spanish', 'American'],
    'Meal Type': ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Brunch', 'Dessert', 'Appetizer', 'Side Dish', 'Beverage', 'Salad'],
    'Difficulty': ['Quick & Easy (under 30 mins)', 'Intermediate', 'Advanced/Gourmet', '5-Ingredient Recipes', 'Beginner-Friendly', 'One-Pot Meals', 'Family-Friendly', 'Meal Prep', 'Budget-Friendly', 'Low Effort'],
    'Diet': ['Vegan', 'Vegetarian', 'Keto', 'Gluten-Free', 'Paleo', 'Low-Carb', 'Dairy-Free', 'Low-Fat', 'Whole30', 'Halal'],
    'Duration': ['Under 30 mins', '30-60 mins', 'Over 60 mins'],
  };

  @override
  Widget build(BuildContext context) {
    // Filter recipes based on selected filters
    List<RecipeItem> filteredRecipes = recipes.where((recipe) {
      bool matchesCategory = true;
      if (selectedCategory != null) {
        if (selectedCategory == 'Cuisine') {
          matchesCategory = selectedSubFilters.isEmpty ||
              selectedSubFilters.contains(recipe.cusine);
        }
        if (selectedCategory == 'Difficulty') {
          matchesCategory = selectedSubFilters.isEmpty ||
              selectedSubFilters.contains(recipe.difficulty);
        }
        if (selectedCategory == 'Duration') {
          if (selectedSubFilters.contains('Under 30 mins') && recipe.timeTaken.inMinutes <= 30) {
            matchesCategory = true;
          } else if (selectedSubFilters.contains('30-60 mins') && recipe.timeTaken.inMinutes > 30 && recipe.timeTaken.inMinutes <= 60) {
            matchesCategory = true;
          } else if (selectedSubFilters.contains('Over 60 mins') && recipe.timeTaken.inMinutes > 60) {
            matchesCategory = true;
          } else {
            matchesCategory = false;
          }
        }
      }
      return matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Recommendation', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F3354),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row containing the search bar and filter icon
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Space between search bar and filter icon
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Handle filter icon press
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        300, // Position for the menu, adjust as needed
                        120, // Y position for the menu
                        10,
                        10,
                      ),
                      items: filterOptions.keys.map((category) {
                        return PopupMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ).then((value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Display subcategories as chips when a category is selected
            if (selectedCategory != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filterOptions[selectedCategory]!
                        .map((subOption) {
                      final isSelected = selectedSubFilters.contains(subOption);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          backgroundColor: Color(0xFF3E5879),
                          selectedColor: Color(0xFF1F3354),
                          checkmarkColor: Colors.white,
                          label: Text(subOption, style: TextStyle(color: Colors.white)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedSubFilters.add(subOption);
                              } else {
                                selectedSubFilters.remove(subOption);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Display Recipe List based on filter
            const SizedBox(height: 10),
            Column(
              children: filteredRecipes.map((recipe) {
                return ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: Text(recipe.name),
                  subtitle: Text('${recipe.cusine} - ${recipe.mealType} - ${recipe.difficulty}'),
                  leading: SizedBox(
                    width: 100,  // Set desired width
                    height: 100,  // Set desired height
                    child: Image.asset(
                      recipe.image,
                      fit: BoxFit.cover,  // Adjust image aspect ratio

                    ),
                  ),
                  trailing: Text('${recipe.timeTaken.inMinutes} min'),
                  onTap: () {
                    // Add action when the item is tapped
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
