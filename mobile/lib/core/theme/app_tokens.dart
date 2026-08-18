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
    brandPrimary: Color(AppColors.terracotta),
    brandAccent: Color(AppColors.honey),
    brandSecondary: Color(AppColors.cocoa),
    brandSecondarySoft: Color(AppColors.honey),
    background: Color(AppColors.cream),
    surface: Color(AppColors.creamSurface),
    card: Color(AppColors.sage),
    onCard: Color(AppColors.cream),
    onCardMuted: Color(0xFFE6EDDD),
    textPrimary: Color(AppColors.cocoa),
    textMuted: Color(0xFF8A7860),
    border: Color(AppColors.sandMist),
    danger: Color(AppColors.terracottaDeep),
    success: Color(AppColors.sage),
    onBrand: Color(AppColors.cream),
    gradientStart: Color(AppColors.creamSurface),
    gradientMid: Color(AppColors.cream),
    gradientEnd: Color(0xFFF3E0BB),
    emergencyStart: Color(AppColors.terracottaDeep),
    emergencyEnd: Color(AppColors.honey),
    pawOpacity: 0.22,
    pawAccent: Color(AppColors.honey),
  );

  static const dark = AppTokens(
    brandPrimary: Color(AppColors.honey),
    brandAccent: Color(AppColors.honey),
    brandSecondary: Color(AppColors.cream),
    brandSecondarySoft: Color(AppColors.terracotta),
    background: Color(AppColors.cocoaDeep),
    surface: Color(AppColors.cocoaSurface),
    card: Color(AppColors.sageDeep),
    onCard: Color(AppColors.cream),
    onCardMuted: Color(0xFFD3DEC7),
    textPrimary: Color(AppColors.cream),
    textMuted: Color(0xFFC7B79C),
    border: Color(0xFF5A452F),
    danger: Color(AppColors.terracottaBright),
    success: Color(AppColors.sageLight),
    onBrand: Color(AppColors.cocoa),
    gradientStart: Color(AppColors.cocoaDeep),
    gradientMid: Color(AppColors.cocoaSurface),
    gradientEnd: Color(0xFF1C120B),
    emergencyStart: Color(AppColors.terracottaBright),
    emergencyEnd: Color(AppColors.honey),
    pawOpacity: 0.16,
    pawAccent: Color(AppColors.terracotta),
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
