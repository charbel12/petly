/// Petly design tokens & app constants
class AppColors {
  static const primary = 0xFF2EC4B6;
  static const secondary = 0xFFFF9F1C;
  static const background = 0xFFF7F9FB;
  static const text = 0xFF1A1A1A;
  static const surface = 0xFFFFFFFF;
  static const muted = 0xFF6B7280;
  static const border = 0xFFE5E7EB;
  static const danger = 0xFFEF4444;
  static const success = 0xFF22C55E;
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
}
