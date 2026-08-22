// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonOr => 'or';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navPets => 'Pets';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navProfile => 'Profile';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEnterEmail => 'Enter your email';

  @override
  String get authEnterValidEmail => 'Enter a valid email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authEnterPassword => 'Enter your password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authGoogleNotConfigured =>
      'Google sign-in is not configured. Add GOOGLE_WEB_CLIENT_ID.';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle =>
      'Sign in to sync your pets across devices and manage your account.';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginSignInButton => 'Sign in';

  @override
  String get loginCreateAccount => 'Create an account';

  @override
  String get loginContinueAsGuest => 'Continue as guest';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle =>
      'Save your pets and pick up where you left off on any device.';

  @override
  String get registerNameLabel => 'Name';

  @override
  String get registerEnterName => 'Enter your name';

  @override
  String get registerPhoneLabel => 'Phone (optional)';

  @override
  String get registerPasswordMinLength => 'Use at least 8 characters';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get registerCreateAccountButton => 'Create account';

  @override
  String get registerAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get forgotTitle => 'Forgot password';

  @override
  String get forgotSubtitle =>
      'Enter your email and we’ll send reset instructions if an account exists. Email delivery isn’t enabled yet — contact support if you need a reset now.';

  @override
  String get forgotSendResetButton => 'Send reset link';

  @override
  String get forgotBackToSignIn => 'Back to sign in';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name 👋';
  }

  @override
  String get homeGreetingGuest => 'Hi there 👋';

  @override
  String get homeFindingLocation => 'Finding your location...';

  @override
  String get homeSearchHint => 'Search vets or clinics...';

  @override
  String get homeEmergencyTitle => 'Emergency Vet';

  @override
  String get homeEmergencySubtitle => 'Find open emergency clinics nearby';

  @override
  String get homeNearbyVetsTitle => 'Nearby vets';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeNoVetsNearby => 'No vets found nearby.';

  @override
  String get homeFeaturedStoresTitle => 'Featured stores';

  @override
  String get homeExploreAction => 'Explore';

  @override
  String get homeNoFeaturedStores => 'No featured stores yet.';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get exploreSearchHint => 'Search by name or area...';

  @override
  String get exploreTabVets => 'Vets';

  @override
  String get exploreTabStores => 'Stores';

  @override
  String get exploreAllPets => 'All pets';

  @override
  String get exploreSortTooltip => 'Sort by';

  @override
  String get exploreSortNearest => 'Nearest';

  @override
  String get exploreSortTopRated => 'Top rated';

  @override
  String get exploreSortByName => 'Name';

  @override
  String get exploreSortFallback => 'Sort';

  @override
  String get exploreFilterEmergency => 'Emergency';

  @override
  String get exploreFilterOpenNow => 'Open now';

  @override
  String get exploreFilterUnder5km => '< 5 km';

  @override
  String get exploreFilterUnder15km => '< 15 km';

  @override
  String get exploreFilterUnder10km => '< 10 km';

  @override
  String get exploreFilterPetStore => 'Pet Store';

  @override
  String get exploreFilterGrooming => 'Grooming';

  @override
  String exploreNoClinicsMatchQuery(String query) {
    return 'No clinics match “$query”';
  }

  @override
  String get exploreTryAnotherArea => 'Try another area or clear filters.';

  @override
  String get exploreNoVetsMatchFilters => 'No vets match your filters';

  @override
  String get exploreAdjustFilters =>
      'Adjust filters or search a different neighborhood.';

  @override
  String exploreNoStoresMatchQuery(String query) {
    return 'No stores match “$query”';
  }

  @override
  String get exploreNoStoresMatchFilters => 'No stores match your filters';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesTabStores => 'Stores';

  @override
  String get favoritesTabVets => 'Vets';

  @override
  String get favoritesNoStoresTitle => 'No favorite stores yet';

  @override
  String get favoritesNoStoresMessage =>
      'Tap the heart on a store to save it here for quick access.';

  @override
  String get favoritesNoVetsTitle => 'No favorite vets yet';

  @override
  String get favoritesNoVetsMessage =>
      'Tap the heart on a clinic to save it here for quick access.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditTooltip => 'Edit profile';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileSignIn => 'Sign in';

  @override
  String get profileCreateAccount => 'Create an account';

  @override
  String get profileSettingsHeader => 'Settings';

  @override
  String get profileNotificationsTitle => 'Notifications';

  @override
  String get profileNotificationsSubtitle => 'Coming in a later phase';

  @override
  String get profileNotificationsSnack =>
      'Push notifications planned for Phase 3';

  @override
  String get profileAppearanceTitle => 'Appearance';

  @override
  String get profileLocationTitle => 'Location';

  @override
  String profileLocationGps(String label) {
    return 'Using GPS · $label';
  }

  @override
  String profileLocationFallback(String label) {
    return 'Fallback · $label';
  }

  @override
  String get profileLocationDetecting => 'Detecting...';

  @override
  String get profileLocationRefreshedSnack => 'Location refreshed';

  @override
  String get profilePartnerDashboardTitle => 'Partner dashboard';

  @override
  String get profilePartnerDashboardSubtitle =>
      'Manage your clinics and stores';

  @override
  String get profileBecomePartnerTitle => 'List your clinic or store';

  @override
  String get profileBecomePartnerSubtitle =>
      'Become a partner to submit listings for review';

  @override
  String get profileSignInPartnerPrompt =>
      'Sign in or register as a partner to list your clinic or store.';

  @override
  String get profileHelpContact => 'Help & contact';

  @override
  String profileTagline(String appName, String status) {
    return '$appName · Phase 2\n$status';
  }

  @override
  String get profileSignedInStatus => 'Signed in';

  @override
  String get profileGuestStatus => 'Guest browsing';

  @override
  String get profileBecomePartnerDialogTitle => 'List your clinic or store';

  @override
  String get profileBecomePartnerDialogContent =>
      'This upgrades your account to a partner so you can submit listings for review. Clients will only see them after approval.';

  @override
  String get profileBecomePartnerConfirm => 'Become a partner';

  @override
  String get profileSignOutDialogTitle => 'Sign out';

  @override
  String get profileSignOutDialogContent =>
      'You can still browse as a guest on this device.';

  @override
  String get profileSignOutSnack => 'Signed out';

  @override
  String get profileEditDialogTitle => 'Edit profile';

  @override
  String get profileEditNameLabel => 'Name';

  @override
  String get profileEditPhoneLabel => 'Phone (optional)';

  @override
  String get profileUpdatedSnack => 'Profile updated';

  @override
  String profileUpdateFailedSnack(String error) {
    return 'Could not update profile: $error';
  }

  @override
  String get profileLanguageTitle => 'Language';

  @override
  String get profileLanguageSystem => 'System default';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageArabic => 'العربية';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get errorConnectionTimeout =>
      'Connection timed out. Check your network and try again.';

  @override
  String get errorCannotReachServer =>
      'Cannot reach Petly servers. Is the API running?';

  @override
  String errorGenericWithCode(int code) {
    return 'Something went wrong ($code)';
  }

  @override
  String get errorUnexpectedNetwork => 'Unexpected network error';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorYoureOffline => 'You’re offline';

  @override
  String get errorSomethingWentWrongTitle => 'Something went wrong';

  @override
  String get offlineBannerText => 'No internet connection';
}
