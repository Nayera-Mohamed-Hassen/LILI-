class CategoryManager {
  static final CategoryManager _instance = CategoryManager._internal();
  factory CategoryManager() => _instance;

  final List<String> _categories = [
    'Food',
    'Cleaning Supplies',
    'Toiletries & Personal Care',
    'Medications & First Aid',
  ];

  CategoryManager._internal();

  List<String> get categories => _categories;

  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
    }
  }
}
