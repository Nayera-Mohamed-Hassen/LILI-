class RecipeItem {
  final String name;
  final String cusine;
  final String mealType;
  final List<String> ingredients;
  final List<String>? steps;
  final Duration timeTaken;
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
      timeTaken: Duration(minutes: json['timeTaken']),
      difficulty: json['difficulty'],
      image: 'assets/recipes/${json['image']}', // prepend assets folder here
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'cusine': cusine,
    'mealType': mealType,
    'ingredients': ingredients,
    'steps': steps,
    'timeTaken': timeTaken.inMinutes,
    'difficulty': difficulty,
    'image': image.replaceFirst('assets/recipes/', ''),
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
