import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get commonOr;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get navPets;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEnterEmail;

  /// No description provided for @authEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authEnterValidEmail;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authEnterPassword;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authGoogleNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not configured. Add GOOGLE_WEB_CLIENT_ID.'**
  String get authGoogleNotConfigured;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your pets across devices and manage your account.'**
  String get loginSubtitle;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignInButton;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get loginCreateAccount;

  /// No description provided for @loginContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get loginContinueAsGuest;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your pets and pick up where you left off on any device.'**
  String get registerSubtitle;

  /// No description provided for @registerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get registerNameLabel;

  /// No description provided for @registerEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get registerEnterName;

  /// No description provided for @registerPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get registerPhoneLabel;

  /// No description provided for @registerPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get registerPasswordMinLength;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerPasswordsDoNotMatch;

  /// No description provided for @registerCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerCreateAccountButton;

  /// No description provided for @registerAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get registerAlreadyHaveAccount;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we’ll send reset instructions if an account exists. Email delivery isn’t enabled yet — contact support if you need a reset now.'**
  String get forgotSubtitle;

  /// No description provided for @forgotSendResetButton.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgotSendResetButton;

  /// No description provided for @forgotBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get forgotBackToSignIn;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name} 👋'**
  String homeGreeting(String name);

  /// No description provided for @homeGreetingGuest.
  ///
  /// In en, this message translates to:
  /// **'Hi there 👋'**
  String get homeGreetingGuest;

  /// No description provided for @homeFindingLocation.
  ///
  /// In en, this message translates to:
  /// **'Finding your location...'**
  String get homeFindingLocation;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search vets or clinics...'**
  String get homeSearchHint;

  /// No description provided for @homeEmergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Vet'**
  String get homeEmergencyTitle;

  /// No description provided for @homeEmergencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find open emergency clinics nearby'**
  String get homeEmergencySubtitle;

  /// No description provided for @homeNearbyVetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby vets'**
  String get homeNearbyVetsTitle;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeNoVetsNearby.
  ///
  /// In en, this message translates to:
  /// **'No vets found nearby.'**
  String get homeNoVetsNearby;

  /// No description provided for @homeFeaturedStoresTitle.
  ///
  /// In en, this message translates to:
  /// **'Featured stores'**
  String get homeFeaturedStoresTitle;

  /// No description provided for @homeExploreAction.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get homeExploreAction;

  /// No description provided for @homeNoFeaturedStores.
  ///
  /// In en, this message translates to:
  /// **'No featured stores yet.'**
  String get homeNoFeaturedStores;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @exploreSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or area...'**
  String get exploreSearchHint;

  /// No description provided for @exploreTabVets.
  ///
  /// In en, this message translates to:
  /// **'Vets'**
  String get exploreTabVets;

  /// No description provided for @exploreTabStores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get exploreTabStores;

  /// No description provided for @exploreAllPets.
  ///
  /// In en, this message translates to:
  /// **'All pets'**
  String get exploreAllPets;

  /// No description provided for @exploreSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get exploreSortTooltip;

  /// No description provided for @exploreSortNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get exploreSortNearest;

  /// No description provided for @exploreSortTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get exploreSortTopRated;

  /// No description provided for @exploreSortByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get exploreSortByName;

  /// No description provided for @exploreSortFallback.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get exploreSortFallback;

  /// No description provided for @exploreFilterEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get exploreFilterEmergency;

  /// No description provided for @exploreFilterOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get exploreFilterOpenNow;

  /// No description provided for @exploreFilterUnder5km.
  ///
  /// In en, this message translates to:
  /// **'< 5 km'**
  String get exploreFilterUnder5km;

  /// No description provided for @exploreFilterUnder15km.
  ///
  /// In en, this message translates to:
  /// **'< 15 km'**
  String get exploreFilterUnder15km;

  /// No description provided for @exploreFilterUnder10km.
  ///
  /// In en, this message translates to:
  /// **'< 10 km'**
  String get exploreFilterUnder10km;

  /// No description provided for @exploreFilterPetStore.
  ///
  /// In en, this message translates to:
  /// **'Pet Store'**
  String get exploreFilterPetStore;

  /// No description provided for @exploreFilterGrooming.
  ///
  /// In en, this message translates to:
  /// **'Grooming'**
  String get exploreFilterGrooming;

  /// No description provided for @exploreNoClinicsMatchQuery.
  ///
  /// In en, this message translates to:
  /// **'No clinics match “{query}”'**
  String exploreNoClinicsMatchQuery(String query);

  /// No description provided for @exploreTryAnotherArea.
  ///
  /// In en, this message translates to:
  /// **'Try another area or clear filters.'**
  String get exploreTryAnotherArea;

  /// No description provided for @exploreNoVetsMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No vets match your filters'**
  String get exploreNoVetsMatchFilters;

  /// No description provided for @exploreAdjustFilters.
  ///
  /// In en, this message translates to:
  /// **'Adjust filters or search a different neighborhood.'**
  String get exploreAdjustFilters;

  /// No description provided for @exploreNoStoresMatchQuery.
  ///
  /// In en, this message translates to:
  /// **'No stores match “{query}”'**
  String exploreNoStoresMatchQuery(String query);

  /// No description provided for @exploreNoStoresMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No stores match your filters'**
  String get exploreNoStoresMatchFilters;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesTabStores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get favoritesTabStores;

  /// No description provided for @favoritesTabVets.
  ///
  /// In en, this message translates to:
  /// **'Vets'**
  String get favoritesTabVets;

  /// No description provided for @favoritesNoStoresTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorite stores yet'**
  String get favoritesNoStoresTitle;

  /// No description provided for @favoritesNoStoresMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a store to save it here for quick access.'**
  String get favoritesNoStoresMessage;

  /// No description provided for @favoritesNoVetsTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorite vets yet'**
  String get favoritesNoVetsTitle;

  /// No description provided for @favoritesNoVetsMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a clinic to save it here for quick access.'**
  String get favoritesNoVetsMessage;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditTooltip;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get profileSignIn;

  /// No description provided for @profileCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get profileCreateAccount;

  /// No description provided for @profileSettingsHeader.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsHeader;

  /// No description provided for @profileNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotificationsTitle;

  /// No description provided for @profileNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Coming in a later phase'**
  String get profileNotificationsSubtitle;

  /// No description provided for @profileNotificationsSnack.
  ///
  /// In en, this message translates to:
  /// **'Push notifications planned for Phase 3'**
  String get profileNotificationsSnack;

  /// No description provided for @profileAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearanceTitle;

  /// No description provided for @profileLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get profileLocationTitle;

  /// No description provided for @profileLocationGps.
  ///
  /// In en, this message translates to:
  /// **'Using GPS · {label}'**
  String profileLocationGps(String label);

  /// No description provided for @profileLocationFallback.
  ///
  /// In en, this message translates to:
  /// **'Fallback · {label}'**
  String profileLocationFallback(String label);

  /// No description provided for @profileLocationDetecting.
  ///
  /// In en, this message translates to:
  /// **'Detecting...'**
  String get profileLocationDetecting;

  /// No description provided for @profileLocationRefreshedSnack.
  ///
  /// In en, this message translates to:
  /// **'Location refreshed'**
  String get profileLocationRefreshedSnack;

  /// No description provided for @profilePartnerDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Partner dashboard'**
  String get profilePartnerDashboardTitle;

  /// No description provided for @profilePartnerDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your clinics and stores'**
  String get profilePartnerDashboardSubtitle;

  /// No description provided for @profileBecomePartnerTitle.
  ///
  /// In en, this message translates to:
  /// **'List your clinic or store'**
  String get profileBecomePartnerTitle;

  /// No description provided for @profileBecomePartnerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Become a partner to submit listings for review'**
  String get profileBecomePartnerSubtitle;

  /// No description provided for @profileSignInPartnerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in or register as a partner to list your clinic or store.'**
  String get profileSignInPartnerPrompt;

  /// No description provided for @profileHelpContact.
  ///
  /// In en, this message translates to:
  /// **'Help & contact'**
  String get profileHelpContact;

  /// No description provided for @profileTagline.
  ///
  /// In en, this message translates to:
  /// **'{appName} · Phase 2\n{status}'**
  String profileTagline(String appName, String status);

  /// No description provided for @profileSignedInStatus.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get profileSignedInStatus;

  /// No description provided for @profileGuestStatus.
  ///
  /// In en, this message translates to:
  /// **'Guest browsing'**
  String get profileGuestStatus;

  /// No description provided for @profileBecomePartnerDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'List your clinic or store'**
  String get profileBecomePartnerDialogTitle;

  /// No description provided for @profileBecomePartnerDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This upgrades your account to a partner so you can submit listings for review. Clients will only see them after approval.'**
  String get profileBecomePartnerDialogContent;

  /// No description provided for @profileBecomePartnerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Become a partner'**
  String get profileBecomePartnerConfirm;

  /// No description provided for @profileSignOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOutDialogTitle;

  /// No description provided for @profileSignOutDialogContent.
  ///
  /// In en, this message translates to:
  /// **'You can still browse as a guest on this device.'**
  String get profileSignOutDialogContent;

  /// No description provided for @profileSignOutSnack.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get profileSignOutSnack;

  /// No description provided for @profileEditDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditDialogTitle;

  /// No description provided for @profileEditNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileEditNameLabel;

  /// No description provided for @profileEditPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get profileEditPhoneLabel;

  /// No description provided for @profileUpdatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdatedSnack;

  /// No description provided for @profileUpdateFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile: {error}'**
  String profileUpdateFailedSnack(String error);

  /// No description provided for @profileLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageTitle;

  /// No description provided for @profileLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get profileLanguageSystem;

  /// No description provided for @profileLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEnglish;

  /// No description provided for @profileLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get profileLanguageArabic;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @errorConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Check your network and try again.'**
  String get errorConnectionTimeout;

  /// No description provided for @errorCannotReachServer.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach Petly servers. Is the API running?'**
  String get errorCannotReachServer;

  /// No description provided for @errorGenericWithCode.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong ({code})'**
  String errorGenericWithCode(int code);

  /// No description provided for @errorUnexpectedNetwork.
  ///
  /// In en, this message translates to:
  /// **'Unexpected network error'**
  String get errorUnexpectedNetwork;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorYoureOffline.
  ///
  /// In en, this message translates to:
  /// **'You’re offline'**
  String get errorYoureOffline;

  /// No description provided for @errorSomethingWentWrongTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorSomethingWentWrongTitle;

  /// No description provided for @offlineBannerText.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get offlineBannerText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
