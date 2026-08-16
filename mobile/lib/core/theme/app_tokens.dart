import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Semantic design tokens for Petly.
///
/// Prefer [AppTokens.of] in widgets so light and dark palettes stay in sync.
class AppTokens {
  const AppTokens({
    required this.brandPrimary,
    required this.brandAccent,
    required this.brandSecondary,
    required this.brandSecondarySoft,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textMuted,
    required this.border,
    required this.danger,
    required this.success,
    required this.onBrand,
    required this.gradientStart,
    required this.gradientMid,
    required this.gradientEnd,
    required this.pawOpacity,
  });

  final Color brandPrimary;
  final Color brandAccent;
  final Color brandSecondary;
  final Color brandSecondarySoft;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textMuted;
  final Color border;
  final Color danger;
  final Color success;
  final Color onBrand;
  final Color gradientStart;
  final Color gradientMid;
  final Color gradientEnd;
  final double pawOpacity;

  static const light = AppTokens(
    brandPrimary: Color(AppColors.primary),
    brandAccent: Color(AppColors.accent),
    brandSecondary: Color(AppColors.secondary),
    brandSecondarySoft: Color(AppColors.secondarySoft),
    background: Color(AppColors.background),
    surface: Color(AppColors.surface),
    textPrimary: Color(AppColors.text),
    textMuted: Color(AppColors.muted),
    border: Color(AppColors.border),
    danger: Color(AppColors.danger),
    success: Color(AppColors.success),
    onBrand: Colors.white,
    gradientStart: Color(0xFFCFF5F1),
    gradientMid: Color(0xFFFFF6EB),
    gradientEnd: Color(0xFFF7F9FB),
    pawOpacity: 0.14,
  );

  static const dark = AppTokens(
    brandPrimary: Color(AppColors.darkPrimary),
    brandAccent: Color(AppColors.accent),
    brandSecondary: Color(0xFFFB923C),
    brandSecondarySoft: Color(AppColors.secondarySoft),
    background: Color(AppColors.darkBackground),
    surface: Color(AppColors.darkSurface),
    textPrimary: Color(AppColors.darkText),
    textMuted: Color(AppColors.darkMuted),
    border: Color(AppColors.darkBorder),
    danger: Color(0xFFF87171),
    success: Color(0xFF4ADE80),
    onBrand: Color(0xFF042F2E),
    gradientStart: Color(0xFF0F2A28),
    gradientMid: Color(0xFF15201F),
    gradientEnd: Color(0xFF121212),
    pawOpacity: 0.07,
  );

  static AppTokens of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

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
