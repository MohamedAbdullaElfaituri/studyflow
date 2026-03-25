import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService(this._preferences);

  final SharedPreferences _preferences;

  static Future<LocalStorageService> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalStorageService(preferences);
  }

  bool containsKey(String key) => _preferences.containsKey(key);

  String? readString(String key) => _preferences.getString(key);

  Future<bool> writeString(String key, String value) {
    return _preferences.setString(key, value);
  }

  Future<bool> remove(String key) {
    return _preferences.remove(key);
  }

  bool? readBool(String key) => _preferences.getBool(key);

  Future<bool> writeBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }
}
