import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_storage.dart';

class KeyValueStorageImpl implements KeyValueStorageService {
  Future<SharedPreferences> getSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Future<void> setKeyValue<T>(String key, T value) async {
    final prefs = await getSharedPreferences();
    switch (T) {
      case const (int):
        prefs.setInt(key, value as int);
        break;

      case const (bool):
        prefs.setBool(key, value as bool);
        break;

      case const (String):
        prefs.setString(key, value as String);
        break;

      default:
        throw UnimplementedError(
          'Set not implemented for type ${T.runtimeType}',
        );
    }
  }

  @override
  Future<T?> getValue<T>(String key) async {
    final prefs = await getSharedPreferences();

    switch (T) {
      case const (int):
        return prefs.getInt(key) as T?;
      case const (bool):
        return prefs.getBool(key) as T?;
      case const (String):
        return prefs.getString(key) as T?;
      default:
        throw UnimplementedError(
          'GET not implemented for type ${T.runtimeType}',
        );
    }
  }

  @override
  Future<bool> removeKey(String key) async {
    final prefs = await getSharedPreferences();
    return await prefs.remove(key);
  }
}
