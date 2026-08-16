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

  static const light = AppTokens(
    brandPrimary: Color(AppColors.blackForest),
    brandAccent: Color(AppColors.sunlitClay),
    brandSecondary: Color(AppColors.copperwood),
    brandSecondarySoft: Color(AppColors.sunlitClay),
    background: Color(AppColors.cornsilk),
    surface: Color(AppColors.cornsilkSurface),
    card: Color(AppColors.oliveLeaf),
    onCard: Color(AppColors.cornsilk),
    onCardMuted: Color(0xFFE8E4C0),
    textPrimary: Color(AppColors.blackForest),
    textMuted: Color(AppColors.oliveLeaf),
    border: Color(AppColors.oliveMist),
    danger: Color(AppColors.copperwood),
    success: Color(AppColors.oliveLeaf),
    onBrand: Color(AppColors.cornsilk),
    gradientStart: Color(0xFFF3E6C0),
    gradientMid: Color(AppColors.cornsilk),
    gradientEnd: Color(0xFFF7F0D2),
    emergencyStart: Color(AppColors.copperwood),
    emergencyEnd: Color(AppColors.sunlitClay),
    pawOpacity: 0.16,
  );

  static const dark = AppTokens(
    brandPrimary: Color(AppColors.sunlitClay),
    brandAccent: Color(AppColors.sunlitClay),
    brandSecondary: Color(AppColors.copperwood),
    brandSecondarySoft: Color(AppColors.sunlitClay),
    background: Color(AppColors.blackForest),
    surface: Color(AppColors.forestCanopy),
    card: Color(AppColors.oliveLeaf),
    onCard: Color(AppColors.cornsilk),
    onCardMuted: Color(0xFFE8E4C0),
    textPrimary: Color(AppColors.cornsilk),
    textMuted: Color(AppColors.sageMist),
    border: Color(AppColors.oliveLeaf),
    danger: Color(AppColors.sunlitClay),
    success: Color(AppColors.sageMist),
    onBrand: Color(AppColors.blackForest),
    gradientStart: Color(AppColors.blackForest),
    gradientMid: Color(AppColors.forestCanopy),
    gradientEnd: Color(0xFF1F2B13),
    emergencyStart: Color(AppColors.copperwood),
    emergencyEnd: Color(AppColors.sunlitClay),
    pawOpacity: 0.10,
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
