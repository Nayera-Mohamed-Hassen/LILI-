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

  @override
  String toString() {
    return this.name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeItem &&
          runtimeType == other.runtimeType &&
          name == other.name; // compare by unique name

  @override
  int get hashCode => name.hashCode;
}
