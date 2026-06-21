import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService({SharedPreferences? prefs}) : _prefs = prefs;

  final SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async =>
      _prefs ?? await SharedPreferences.getInstance();

  Future<String?> getString(String key) async {
    final p = await prefs;
    return p.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final p = await prefs;
    await p.setString(key, value);
  }

  Future<bool?> getBool(String key) async {
    final p = await prefs;
    return p.getBool(key);
  }

  Future<void> setBool(String key, bool value) async {
    final p = await prefs;
    await p.setBool(key, value);
  }

  Future<int?> getInt(String key) async {
    final p = await prefs;
    return p.getInt(key);
  }

  Future<void> setInt(String key, int value) async {
    final p = await prefs;
    await p.setInt(key, value);
  }

  Future<void> remove(String key) async {
    final p = await prefs;
    await p.remove(key);
  }
}
