class FcmTokenRegistry {
  static String? token;

  static void update(String? value) => token = value;

  static void clear() => token = null;
}
