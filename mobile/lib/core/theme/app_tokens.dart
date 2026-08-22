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
    required this.card,
    required this.onCard,
    required this.onCardMuted,
    required this.textPrimary,
    required this.textMuted,
    required this.border,
    required this.danger,
    required this.success,
    required this.onBrand,
    required this.gradientStart,
    required this.gradientMid,
    required this.gradientEnd,
    required this.emergencyStart,
    required this.emergencyEnd,
    required this.pawOpacity,
    required this.pawAccent,
  });

  final Color brandPrimary;
  final Color brandAccent;
  final Color brandSecondary;
  final Color brandSecondarySoft;
  final Color background;
  final Color surface;
  final Color card;
  final Color onCard;
  final Color onCardMuted;
  final Color textPrimary;
  final Color textMuted;
  final Color border;
  final Color danger;
  final Color success;
  final Color onBrand;
  final Color gradientStart;
  final Color gradientMid;
  final Color gradientEnd;
  final Color emergencyStart;
  final Color emergencyEnd;
  final double pawOpacity;

  /// Second tint the background paw pattern alternates with, for variety.
  final Color pawAccent;

  static const light = AppTokens(
    brandPrimary: Color(AppColors.teal600),
    brandAccent: Color(AppColors.amber500),
    brandSecondary: Color(AppColors.slate900),
    brandSecondarySoft: Color(AppColors.amber500),
    background: Color(AppColors.slate50),
    surface: Color(AppColors.white),
    card: Color(AppColors.white),
    onCard: Color(AppColors.slate900),
    onCardMuted: Color(AppColors.slate500),
    textPrimary: Color(AppColors.slate900),
    textMuted: Color(AppColors.slate500),
    border: Color(AppColors.slate200),
    danger: Color(AppColors.rose500),
    success: Color(AppColors.emerald500),
    onBrand: Color(AppColors.white),
    gradientStart: Color(AppColors.slate50),
    gradientMid: Color(AppColors.slate50),
    gradientEnd: Color(0xFFEEF2F7),
    emergencyStart: Color(AppColors.rose500),
    emergencyEnd: Color(0xFFE11D48),
    pawOpacity: 0.32,
    pawAccent: Color(AppColors.amber500),
  );

  static const dark = AppTokens(
    brandPrimary: Color(AppColors.teal400),
    brandAccent: Color(AppColors.amber400),
    brandSecondary: Color(AppColors.slate50),
    brandSecondarySoft: Color(AppColors.amber400),
    background: Color(AppColors.slate950),
    surface: Color(AppColors.slate800),
    card: Color(AppColors.slate800),
    onCard: Color(AppColors.slate50),
    onCardMuted: Color(AppColors.slate400),
    textPrimary: Color(AppColors.slate50),
    textMuted: Color(AppColors.slate400),
    border: Color(AppColors.slate700),
    danger: Color(AppColors.rose400),
    success: Color(AppColors.emerald400),
    onBrand: Color(AppColors.slate950),
    gradientStart: Color(AppColors.slate950),
    gradientMid: Color(0xFF0F172A),
    gradientEnd: Color(0xFF020617),
    emergencyStart: Color(AppColors.rose400),
    emergencyEnd: Color(0xFFF43F5E),
    pawOpacity: 0.20,
    pawAccent: Color(AppColors.amber400),
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
