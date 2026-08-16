/// Petly design tokens & app constants
class AppColors {
  // Palette 3 — olive / forest / cornsilk / clay / copper
  static const oliveLeaf = 0xFF606C38;
  static const blackForest = 0xFF283618;
  static const cornsilk = 0xFFFEFAE0;
  static const sunlitClay = 0xFFDDA15E;
  static const copperwood = 0xFFBC6C25;

  /// Tints and shades mixed only from the five palette colors.
  static const cornsilkSurface = 0xFFFFFDF4;
  static const oliveMist = 0xFFE1E0C2;
  static const forestCanopy = 0xFF3C4923;
  static const sageMist = 0xFFB7BA94;

  // Semantic — light
  static const primary = oliveLeaf;
  static const accent = sunlitClay;
  static const secondary = copperwood;
  static const secondarySoft = sunlitClay;
  static const background = cornsilk;
  static const text = blackForest;
  static const surface = cornsilkSurface;
  static const muted = oliveLeaf;
  static const border = oliveMist;
  static const danger = copperwood;
  static const success = oliveLeaf;

  // Semantic — dark
  static const darkBackground = blackForest;
  static const darkSurface = forestCanopy;
  static const darkText = cornsilk;
  static const darkMuted = sageMist;
  static const darkBorder = oliveLeaf;
  static const darkPrimary = sunlitClay;
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

  /// WhatsApp brand green — kept as the vendor color, not part of the app palette.
  static const whatsappGreen = 0xFF25D366;
}
