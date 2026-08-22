import 'package:flutter/material.dart';
import 'package:petly/l10n/app_localizations.dart';

/// Wraps [home] in a [MaterialApp] configured with the app's localization
/// delegates, mirroring the setup in `lib/main.dart`. Any widget under test
/// that calls `AppLocalizations.of(context)!` needs this (or an equivalent
/// wrapper) or it throws a null-check error.
Widget localizedApp({required Widget home, Locale? locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
