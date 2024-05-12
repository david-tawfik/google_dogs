class UserIdStorage {
  static String userId = '1';

  static void setUserId(String id) {
    userId = id;
  }

  static String getUserId() {
    return userId;
  }
}