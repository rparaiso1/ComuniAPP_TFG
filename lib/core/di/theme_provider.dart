import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';
import '../di/providers.dart';

const _kThemeModeKey = 'theme_mode';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  late final LocalStorageService _storage;

  @override
  ThemeMode build() {
    _storage = ref.watch(localStorageProvider);
    _loadSavedMode();
    return ThemeMode.system;
  }

  void _loadSavedMode() {
    final saved = _storage.getSetting(_kThemeModeKey) as String?;
    if (saved != null) {
      switch (saved) {
        case 'light':
          state = ThemeMode.light;
        case 'dark':
          state = ThemeMode.dark;
        default:
          state = ThemeMode.system;
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _storage.saveSetting(_kThemeModeKey, mode.name);
  }

  void toggle() {
    switch (state) {
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
      case ThemeMode.dark:
        setThemeMode(ThemeMode.system);
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  () => ThemeModeNotifier(),
);
