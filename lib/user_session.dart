class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  int? userId = 0;

  void setUserId(int id) {
    userId = id;
  }

  int? getUserId() {
    return userId;
  }
}
