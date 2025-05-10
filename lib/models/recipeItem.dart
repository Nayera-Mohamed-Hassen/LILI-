
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
