class RecipeItem {
  final String name;
  final String cusine;
  final String mealType;
  final List<String> ingredients;
  final List<String> availableIngredients;
  final List<String> missingIngredients;
  final String ingredientsCoverage;
  final List<String>? steps;
  final String timeTaken; // now String
  final String difficulty;
  final String image;

  RecipeItem({
    required this.name,
    required this.cusine,
    required this.mealType,
    required this.ingredients,
    required this.availableIngredients,
    required this.missingIngredients,
    required this.ingredientsCoverage,
    this.steps,
    required this.timeTaken,
    required this.difficulty,
    required this.image,
  });

  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    return RecipeItem(
      name: json['name'] ?? '',
      cusine: json['cusine'] ?? '',
      mealType: json['mealType'] ?? '',
      ingredients: json['ingredients'] != null ? List<String>.from(json['ingredients']) : [],
      availableIngredients: json['available_ingredients'] != null ? List<String>.from(json['available_ingredients']) : [],
      missingIngredients: json['missing_ingredients'] != null ? List<String>.from(json['missing_ingredients']) : [],
      ingredientsCoverage: json['ingredients_coverage'] ?? '0%',
      steps: json['steps'] != null ? List<String>.from(json['steps']) : null,
      timeTaken: json['timeTaken']?.toString() ?? '',
      difficulty: json['difficulty'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'cusine': cusine,
    'mealType': mealType,
    'ingredients': ingredients,
    'available_ingredients': availableIngredients,
    'missing_ingredients': missingIngredients,
    'ingredients_coverage': ingredientsCoverage,
    'steps': steps,
    'timeTaken': timeTaken,
    'difficulty': difficulty,
    'image': image,
  };

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeItem &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
