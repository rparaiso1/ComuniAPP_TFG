import 'package:hive_flutter/hive_flutter.dart';
import 'app_logger.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  static const String _userBox = 'user_box';
  static const String _cacheBox = 'cache_box';
  static const String _settingsBox = 'settings_box';

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      await Hive.openBox(_userBox);
      await Hive.openBox(_cacheBox);
      await Hive.openBox(_settingsBox);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize local storage', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // User data
  Future<void> saveUserData(String key, dynamic value) async {
    final box = Hive.box(_userBox);
    await box.put(key, value);
  }

  dynamic getUserData(String key) {
    final box = Hive.box(_userBox);
    return box.get(key);
  }

  Future<void> deleteUserData(String key) async {
    final box = Hive.box(_userBox);
    await box.delete(key);
  }

  Future<void> clearUserData() async {
    final box = Hive.box(_userBox);
    await box.clear();
  }

  // Cache data
  Future<void> saveCache(String key, dynamic value) async {
    final box = Hive.box(_cacheBox);
    await box.put(key, value);
  }

  dynamic getCache(String key) {
    final box = Hive.box(_cacheBox);
    return box.get(key);
  }

  Future<void> deleteCache(String key) async {
    final box = Hive.box(_cacheBox);
    await box.delete(key);
  }

  Future<void> clearCache() async {
    final box = Hive.box(_cacheBox);
    await box.clear();
  }

  // Settings
  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(_settingsBox);
    await box.put(key, value);
  }

  dynamic getSetting(String key) {
    final box = Hive.box(_settingsBox);
    return box.get(key);
  }

  Future<void> deleteSetting(String key) async {
    final box = Hive.box(_settingsBox);
    await box.delete(key);
  }

  Future<void> clearSettings() async {
    final box = Hive.box(_settingsBox);
    await box.clear();
  }
}
