import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/providers.dart';
import '../services/local_storage_service.dart';

const _kLocaleKey = 'app_locale';

class LocaleNotifier extends Notifier<Locale> {
  late final LocalStorageService _storage;

  @override
  Locale build() {
    _storage = ref.watch(localStorageProvider);
    final saved = _storage.getSetting(_kLocaleKey) as String?;
    if (saved != null) {
      return Locale(saved);
    }
    return const Locale('es');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _storage.saveSetting(_kLocaleKey, locale.languageCode);
  }

  void toggleLocale() {
    final next = state.languageCode == 'es'
        ? const Locale('en')
        : const Locale('es');
    setLocale(next);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  () => LocaleNotifier(),
);
