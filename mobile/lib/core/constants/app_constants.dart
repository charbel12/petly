/// Petly design tokens & app constants
class AppColors {
  // Cozy pet-friendly palette — cream / terracotta / sage / honey / cocoa
  static const cream = 0xFFFBF1DF;
  static const terracotta = 0xFFC1592E;
  static const sage = 0xFF7E9473;
  static const honey = 0xFFECA83D;
  static const cocoa = 0xFF4A3324;

  /// Tints and shades mixed only from the five palette colors.
  static const creamSurface = 0xFFFFF8EC;
  static const sandMist = 0xFFEEDFC0;
  static const cocoaDeep = 0xFF2B1D12;
  static const cocoaSurface = 0xFF3C2A1B;
  static const terracottaDeep = 0xFF8E3E22;
  static const terracottaBright = 0xFFD9663F;
  static const sageDeep = 0xFF5C7052;
  static const sageLight = 0xFF9AB58C;

  // Semantic — light
  static const primary = terracotta;
  static const accent = honey;
  static const secondary = cocoa;
  static const secondarySoft = honey;
  static const background = cream;
  static const text = cocoa;
  static const surface = creamSurface;
  static const muted = terracotta;
  static const border = sandMist;
  static const danger = terracottaDeep;
  static const success = sage;

  // Semantic — dark
  static const darkBackground = cocoaDeep;
  static const darkSurface = cocoaSurface;
  static const darkText = cream;
  static const darkMuted = honey;
  static const darkBorder = terracotta;
  static const darkPrimary = honey;
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
}
