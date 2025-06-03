import 'package:flutter/material.dart';
import 'package:LILI/models/recipeItem.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({Key? key}) : super(key: key);

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  final List<String> _ingredients = [];
  final List<String> _steps = [];

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  // Filter options from your map
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

  // Selected values for combo boxes
  String? _selectedCuisine;
  String? _selectedMealType;
  String? _selectedDifficulty;
  String? _selectedDiet;
  String? _selectedDuration;

  // Controllers for new steps input
  final List<TextEditingController> _stepControllers = [
    TextEditingController(),
  ];

  void _addIngredient() {
    final text = _ingredientsController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _ingredients.add(text);
        _ingredientsController.clear();
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStepField(int index) {
    setState(() {
      _stepControllers[index].dispose();
      _stepControllers.removeAt(index);
    });
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final stepsList =
          _stepControllers
              .map((controller) => controller.text.trim())
              .where((step) => step.isNotEmpty)
              .toList();

      final newRecipe = RecipeItem(
        name: _nameController.text.trim(),
        cusine: _selectedCuisine ?? '',
        mealType: _selectedMealType ?? '',
        ingredients: _ingredients,
        timeTaken: _selectedDuration ?? '',
        difficulty: _selectedDifficulty ?? '',
        image: _pickedImage?.path ?? '',
        steps: stepsList.isEmpty ? null : stepsList,
        availableIngredients: [],
        missingIngredients: [],
        ingredientsCoverage: '',
      );

      Navigator.pop(context, newRecipe);
    }
  }

  Duration _durationToDuration(String? durationStr) {
    switch (durationStr) {
      case 'Under 30 mins':
        return Duration(minutes: 30);
      case '30-60 mins':
        return Duration(minutes: 45);
      case 'Over 60 mins':
        return Duration(hours: 1);
      default:
        return Duration(minutes: 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Add Recipe',
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24),
            ),
            child: IconButton(
              icon: Icon(Icons.save, color: Colors.white.withOpacity(0.9)),
              onPressed: _saveRecipe,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F3354), Color(0xFF3E5879)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                      image:
                          _pickedImage != null
                              ? DecorationImage(
                                image: FileImage(_pickedImage!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        _pickedImage == null
                            ? Icon(
                              Icons.add_a_photo,
                              color: Colors.white.withOpacity(0.7),
                              size: 40,
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Recipe Name',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red.shade300),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter a recipe name'
                              : null,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  'Cuisine',
                  filterOptions['Cuisine']!,
                  _selectedCuisine,
                  (value) => setState(() => _selectedCuisine = value),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  'Meal Type',
                  filterOptions['Meal Type']!,
                  _selectedMealType,
                  (value) => setState(() => _selectedMealType = value),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  'Difficulty',
                  filterOptions['Difficulty']!,
                  _selectedDifficulty,
                  (value) => setState(() => _selectedDifficulty = value),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  'Duration',
                  filterOptions['Duration']!,
                  _selectedDuration,
                  (value) => setState(() => _selectedDuration = value),
                ),
                const SizedBox(height: 24),
                Text(
                  'Ingredients',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ingredientsController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add ingredient',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        onPressed: _addIngredient,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _ingredients.map((ingredient) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ingredient,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _ingredients.remove(ingredient);
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Steps',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ..._stepControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter step ${index + 1}',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.15),
                            ),
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_stepControllers.length > 1)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.remove,
                                color: Colors.red.shade300,
                              ),
                              onPressed: () => _removeStepField(index),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      onPressed: _addStepField,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    void Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(
            'Select $label',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: Colors.white.withOpacity(0.7),
          ),
          isExpanded: true,
          dropdownColor: const Color(0xFF1F3354),
          style: const TextStyle(color: Colors.white),
          items:
              items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
