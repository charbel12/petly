/// Petly design tokens & app constants
class AppColors {
  // Light — teal / amber / slate
  static const teal600 = 0xFF0D8275;
  static const amber500 = 0xFFF59E0B;
  static const slate50 = 0xFFF8FAFC;
  static const white = 0xFFFFFFFF;
  static const slate200 = 0xFFE2E8F0;
  static const slate900 = 0xFF0F172A;
  static const slate500 = 0xFF64748B;
  static const emerald500 = 0xFF10B981;
  static const rose500 = 0xFFF43F5E;

  // Dark — brighter teal/amber on deep slate
  static const teal400 = 0xFF2DD4BF;
  static const amber400 = 0xFFFBBF24;
  static const slate950 = 0xFF0B0F19;
  static const slate800 = 0xFF1E293B;
  static const slate700 = 0xFF334155;
  static const slate400 = 0xFF94A3B8;
  static const emerald400 = 0xFF34D399;
  static const rose400 = 0xFFFB7185;

  // Semantic — light
  static const primary = teal600;
  static const accent = amber500;
  static const secondary = slate900;
  static const secondarySoft = amber500;
  static const background = slate50;
  static const text = slate900;
  static const surface = white;
  static const muted = slate500;
  static const border = slate200;
  static const danger = rose500;
  static const success = emerald500;

  // Semantic — dark
  static const darkBackground = slate950;
  static const darkSurface = slate800;
  static const darkText = slate50;
  static const darkMuted = slate400;
  static const darkBorder = slate700;
  static const darkPrimary = teal400;
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

  /// Hosted API. Override locally via --dart-define=API_BASE_URL=...
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://petly-6f6c.onrender.com',
  );

  static const whatsappMessage =
      'Hello, I found you on Petly and would like to get in touch.';

  static const pawAsset = 'assets/paws/paw.svg';

  /// WhatsApp brand green — kept as the vendor color, not part of the app palette.
  static const whatsappGreen = 0xFF25D366;

  /// Google OAuth web client ID (ID-token audience). Set via
  /// `--dart-define=GOOGLE_WEB_CLIENT_ID=...`.
  static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  /// iOS OAuth client ID. Set via `--dart-define=GOOGLE_IOS_CLIENT_ID=...`.
  static const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  static bool get googleSignInConfigured => googleWebClientId.isNotEmpty;
}
