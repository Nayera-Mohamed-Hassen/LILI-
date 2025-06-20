class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  int recipesCount = 1;
  String? userId = '';

  void setUserId(String id) {
    userId = id;
  }

  String? getUserId() {
    return userId;
  }

  void setRecipeCount(int count) {
    recipesCount = count;
  }

  int getRecipeCount() {
    return recipesCount;
  }

  void incrementRecipeCount() {
    recipesCount += 1;
  }
}
