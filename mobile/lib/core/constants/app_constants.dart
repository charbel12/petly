/// Petly design tokens & app constants
class AppColors {
  /// Teal-700: AA contrast for white-on-teal buttons and teal-on-white text.
  static const primary = 0xFF0F766E;

  /// Original brand teal for gradients, paw motifs, and decorative fills.
  static const accent = 0xFF2EC4B6;

  /// Orange-700: small-text contrast on light surfaces.
  static const secondary = 0xFFC2410C;

  /// Soft orange for chips, banners, and decorative accents.
  static const secondarySoft = 0xFFFF9F1C;

  static const background = 0xFFF7F9FB;
  static const text = 0xFF1A1A1A;
  static const surface = 0xFFFFFFFF;
  static const muted = 0xFF4B5563;
  static const border = 0xFFE5E7EB;
  static const danger = 0xFFDC2626;
  static const success = 0xFF15803D;

  static const darkBackground = 0xFF0F1716;
  static const darkSurface = 0xFF1A2423;
  static const darkText = 0xFFF3F4F6;
  static const darkMuted = 0xFF9CA3AF;
  static const darkBorder = 0xFF2A3A38;
  static const darkPrimary = 0xFF2DD4BF;
}

class AppConstants {
  static const appName = 'Petly';
  static const altName = 'Pawly';

  /// Default Beirut coordinates for nearby distance calculations.
  static const defaultLat = 33.8938;
  static const defaultLng = 35.5018;
  static const defaultLocationLabel = 'Beirut, Lebanon';

  /// Demo user seeded by the backend (Phase 1 — no auth yet).
  static const demoUserId = '11111111-1111-1111-1111-111111111111';
  static const demoUserName = 'Demo User';
  static const demoUserPhone = '+96171123456';

  /// Android emulator → host machine. Override via --dart-define=API_BASE_URL=...
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const whatsappMessage =
      'Hello, I found you on Petly and would like to get in touch.';

  static const pawAsset = 'assets/paws/paw.svg';
}
