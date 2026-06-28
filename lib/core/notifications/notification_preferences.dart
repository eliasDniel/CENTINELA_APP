import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferences {
  NotificationPreferences._();

  static const storageKey = 'notifications_push_enabled';

  static bool _enabled = true;
  static bool _loaded = false;

  static bool get enabled => _enabled;

  static Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(storageKey) ?? true;
    _loaded = true;
  }

  static Future<bool> setEnabled(bool value) async {
    _enabled = value;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(storageKey, value);
    return value;
  }
}
