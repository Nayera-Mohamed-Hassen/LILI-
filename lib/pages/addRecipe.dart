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
        title: const Text('Add Recipes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F3354),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      _pickedImage != null ? FileImage(_pickedImage!) : null,
                  child:
                      _pickedImage == null
                          ? const Icon(Icons.add_a_photo, color: Colors.white)
                          : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Recipe Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please enter a recipe name'
                            : null,
              ),
              const SizedBox(height: 16),

              // Dropdowns for filters
              _buildDropdown(
                'Cuisine',
                filterOptions['Cuisine'],
                _selectedCuisine,
                (val) {
                  setState(() => _selectedCuisine = val);
                },
              ),
              _buildDropdown(
                'Meal Type',
                filterOptions['Meal Type'],
                _selectedMealType,
                (val) {
                  setState(() => _selectedMealType = val);
                },
              ),
              _buildDropdown(
                'Difficulty',
                filterOptions['Difficulty'],
                _selectedDifficulty,
                (val) {
                  setState(() => _selectedDifficulty = val);
                },
              ),
              _buildDropdown('Diet', filterOptions['Diet'], _selectedDiet, (
                val,
              ) {
                setState(() => _selectedDiet = val);
              }),
              _buildDropdown(
                'Duration',
                filterOptions['Duration'],
                _selectedDuration,
                (val) {
                  setState(() => _selectedDuration = val);
                },
              ),

              const SizedBox(height: 16),

              // Ingredients input
              TextFormField(
                controller: _ingredientsController,
                decoration: InputDecoration(
                  labelText: 'Add Ingredient',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addIngredient,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                children:
                    _ingredients
                        .map((ingredient) => Chip(label: Text(ingredient)))
                        .toList(),
              ),

              const SizedBox(height: 24),
              const Text(
                "Steps",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _stepControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _stepControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Step ${index + 1}',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          if (_stepControllers.length > 1) {
                            _removeStepField(index);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Step"),
                onPressed: _addStepField,
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveRecipe,
                child: const Text("Save Recipe"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String>? items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label),
        value: selectedValue,
        items:
            items
                ?.map(
                  (item) => DropdownMenuItem(value: item, child: Text(item)),
                )
                .toList(),
        onChanged: onChanged,
        validator:
            (value) =>
                value == null || value.isEmpty ? 'Please select $label' : null,
      ),
    );
  }
}
