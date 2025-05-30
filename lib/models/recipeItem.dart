class RecipeItem {
  final String name;
  final String cusine;
  final String mealType;
  final List<String> ingredients;
  final List<String>? steps;
  final String timeTaken; // now String
  final String difficulty;
  final String image;

  RecipeItem({
    required this.name,
    required this.cusine,
    required this.mealType,
    required this.ingredients,
    this.steps,
    required this.timeTaken,
    required this.difficulty,
    required this.image,
  });

  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    return RecipeItem(
      name: json['name'],
      cusine: json['cusine'],
      mealType: json['mealType'],
      ingredients: List<String>.from(json['ingredients']),
      steps: json['steps'] != null ? List<String>.from(json['steps']) : null,
      timeTaken: json['timeTaken'],
      difficulty: json['difficulty'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'cusine': cusine,
    'mealType': mealType,
    'ingredients': ingredients,
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
