import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const localePrefsKey = 'petly_locale';

/// Persists the user's chosen app language. `null` means "follow system".
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(localePrefsKey);
    final parsed = parseLocale(raw);
    if (parsed != state) {
      state = parsed;
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(localePrefsKey);
    } else {
      await prefs.setString(localePrefsKey, locale.languageCode);
    }
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

Locale? parseLocale(String? raw) {
  switch (raw) {
    case 'en':
      return const Locale('en');
    case 'ar':
      return const Locale('ar');
    default:
      return null;
  }
}
