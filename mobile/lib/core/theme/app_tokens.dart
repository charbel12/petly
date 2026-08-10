import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Semantic design tokens for Petly.
///
/// Values map to the raw palette in [AppColors]. Widgets and the theme should
/// prefer these semantic names so a future re-theme (Phase 4: dark mode,
/// contrast tuning) mostly changes this one file.
class AppTokens {
  AppTokens._();

  // Semantic colors
  static const Color brandPrimary = Color(AppColors.primary);
  static const Color brandSecondary = Color(AppColors.secondary);
  static const Color background = Color(AppColors.background);
  static const Color surface = Color(AppColors.surface);
  static const Color textPrimary = Color(AppColors.text);
  static const Color textMuted = Color(AppColors.muted);
  static const Color border = Color(AppColors.border);
  static const Color danger = Color(AppColors.danger);
  static const Color success = Color(AppColors.success);
  static const Color onBrand = Colors.white;

  // Spacing scale
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  // Corner radii
  static const double radiusSm = 12;
  static const double radiusMd = 14;
  static const double radiusLg = 16;

  // Control sizing
  static const double controlHeight = 52;
}
