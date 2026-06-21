import 'package:shared_preferences/shared_preferences.dart';
import 'preference_key.dart';

class PreferencesService {
  PreferencesService({SharedPreferences? prefs}) : _prefs = prefs;

  final SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async =>
      _prefs ?? await SharedPreferences.getInstance();

  Future<String?> getString(PreferenceKey key) async {
    final p = await prefs;
    return p.getString(key.key);
  }

  Future<void> setString(PreferenceKey key, String value) async {
    final p = await prefs;
    await p.setString(key.key, value);
  }

  Future<bool?> getBool(PreferenceKey key) async {
    final p = await prefs;
    return p.getBool(key.key);
  }

  Future<void> setBool(PreferenceKey key, bool value) async {
    final p = await prefs;
    await p.setBool(key.key, value);
  }

  Future<int?> getInt(PreferenceKey key) async {
    final p = await prefs;
    return p.getInt(key.key);
  }

  Future<void> setInt(PreferenceKey key, int value) async {
    final p = await prefs;
    await p.setInt(key.key, value);
  }

  Future<void> remove(PreferenceKey key) async {
    final p = await prefs;
    await p.remove(key.key);
  }
}
