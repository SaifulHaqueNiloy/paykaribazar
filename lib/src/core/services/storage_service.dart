import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
  Future<void> clear();
}

class SharedPrefsService implements StorageService {
  final SharedPreferences _prefs;
  
  SharedPrefsService(this._prefs);
  
  @override
  Future<String?> getString(String key) async => _prefs.getString(key);
  
  @override
  Future<void> setString(String key, String value) async => 
      _prefs.setString(key, value);
  
  @override
  Future<void> remove(String key) async => _prefs.remove(key);
  
  @override
  Future<void> clear() async => _prefs.clear();
}
