class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  int recipesCount = 1;
  int? userId = 0;

  void setUserId(int id) {
    userId = id;
  }

  int? getUserId() {
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
