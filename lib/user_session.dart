class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  int recipesCount = 1;
  String? userId = '';
  String? username = '';
  String? name = '';
  String? houseId = '';

  void setUserId(String id) {
    userId = id;
  }

  void setUsername(String name) {
    username = name;
  }

  void setName(String n) {
    name = n;
  }

  void setHouseId(String id) {
    houseId = id;
  }

  String? getUserId() {
    return userId;
  }

  String? getUsername() {
    return username;
  }

  String? getName() {
    return name;
  }

  String? getHouseId() {
    return houseId;
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
