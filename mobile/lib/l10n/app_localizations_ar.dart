// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonTryAgain => 'حاول مرة أخرى';

  @override
  String get commonSubmit => 'إرسال';

  @override
  String get commonOr => 'أو';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navExplore => 'استكشاف';

  @override
  String get navPets => 'حيواناتي';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authEnterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get authEnterValidEmail => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authEnterPassword => 'أدخل كلمة المرور';

  @override
  String get authShowPassword => 'إظهار كلمة المرور';

  @override
  String get authHidePassword => 'إخفاء كلمة المرور';

  @override
  String get authContinueWithGoogle => 'الاستمرار مع Google';

  @override
  String get authGoogleNotConfigured =>
      'تسجيل الدخول عبر Google غير مُفعّل. أضف GOOGLE_WEB_CLIENT_ID.';

  @override
  String get loginTitle => 'أهلاً بعودتك';

  @override
  String get loginSubtitle =>
      'سجّل الدخول لمزامنة حيواناتك بين الأجهزة وإدارة حسابك.';

  @override
  String get loginForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get loginSignInButton => 'تسجيل الدخول';

  @override
  String get loginCreateAccount => 'إنشاء حساب';

  @override
  String get loginContinueAsGuest => 'الاستمرار كزائر';

  @override
  String get registerTitle => 'إنشاء حسابك';

  @override
  String get registerSubtitle =>
      'احفظ بيانات حيواناتك واستمرّ من حيث توقفت على أي جهاز.';

  @override
  String get registerNameLabel => 'الاسم';

  @override
  String get registerEnterName => 'أدخل اسمك';

  @override
  String get registerPhoneLabel => 'رقم الهاتف (اختياري)';

  @override
  String get registerPasswordMinLength => 'استخدم 8 أحرف على الأقل';

  @override
  String get registerConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get registerPasswordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get registerCreateAccountButton => 'إنشاء حساب';

  @override
  String get registerAlreadyHaveAccount => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get forgotTitle => 'نسيت كلمة المرور';

  @override
  String get forgotSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل تعليمات إعادة التعيين إذا وُجد حساب مرتبط به. إرسال البريد غير مُفعّل بعد — تواصل مع الدعم إذا احتجت إلى إعادة تعيين كلمة المرور الآن.';

  @override
  String get forgotSendResetButton => 'إرسال رابط إعادة التعيين';

  @override
  String get forgotBackToSignIn => 'الرجوع لتسجيل الدخول';

  @override
  String homeGreeting(String name) {
    return 'أهلاً، $name 👋';
  }

  @override
  String get homeGreetingGuest => 'أهلاً بك 👋';

  @override
  String get homeFindingLocation => 'جارٍ تحديد موقعك...';

  @override
  String get homeSearchHint => 'ابحث عن عيادات بيطرية...';

  @override
  String get homeEmergencyTitle => 'طبيب بيطري للطوارئ';

  @override
  String get homeEmergencySubtitle => 'ابحث عن عيادات الطوارئ المفتوحة قربك';

  @override
  String get homeNearbyVetsTitle => 'عيادات قريبة منك';

  @override
  String get homeSeeAll => 'عرض الكل';

  @override
  String get homeNoVetsNearby => 'لا توجد عيادات بيطرية قريبة.';

  @override
  String get homeFeaturedStoresTitle => 'متاجر مميزة';

  @override
  String get homeExploreAction => 'استكشاف';

  @override
  String get homeNoFeaturedStores => 'لا توجد متاجر مميزة حاليًا.';

  @override
  String get exploreTitle => 'استكشاف';

  @override
  String get exploreSearchHint => 'ابحث بالاسم أو المنطقة...';

  @override
  String get exploreTabVets => 'عيادات';

  @override
  String get exploreTabStores => 'متاجر';

  @override
  String get exploreAllPets => 'كل الحيوانات';

  @override
  String get exploreSortTooltip => 'ترتيب حسب';

  @override
  String get exploreSortNearest => 'الأقرب';

  @override
  String get exploreSortTopRated => 'الأعلى تقييمًا';

  @override
  String get exploreSortByName => 'الاسم';

  @override
  String get exploreSortFallback => 'ترتيب';

  @override
  String get exploreFilterEmergency => 'طوارئ';

  @override
  String get exploreFilterOpenNow => 'مفتوح الآن';

  @override
  String get exploreFilterUnder5km => 'أقل من ٥ كم';

  @override
  String get exploreFilterUnder15km => 'أقل من ١٥ كم';

  @override
  String get exploreFilterUnder10km => 'أقل من ١٠ كم';

  @override
  String get exploreFilterPetStore => 'متجر حيوانات';

  @override
  String get exploreFilterGrooming => 'تنظيف وتجميل';

  @override
  String exploreNoClinicsMatchQuery(String query) {
    return 'لا توجد عيادات مطابقة لـ «$query»';
  }

  @override
  String get exploreTryAnotherArea => 'جرّب منطقة أخرى أو ألغِ الفلاتر.';

  @override
  String get exploreNoVetsMatchFilters =>
      'لا توجد عيادات مطابقة للفلاتر المحددة';

  @override
  String get exploreAdjustFilters => 'عدّل الفلاتر أو ابحث في منطقة مختلفة.';

  @override
  String exploreNoStoresMatchQuery(String query) {
    return 'لا توجد متاجر مطابقة لـ «$query»';
  }

  @override
  String get exploreNoStoresMatchFilters =>
      'لا توجد متاجر مطابقة للفلاتر المحددة';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get favoritesTabStores => 'متاجر';

  @override
  String get favoritesTabVets => 'عيادات';

  @override
  String get favoritesNoStoresTitle => 'لا توجد متاجر مفضلة بعد';

  @override
  String get favoritesNoStoresMessage =>
      'اضغط على أيقونة القلب في أي متجر لحفظه هنا للوصول السريع.';

  @override
  String get favoritesNoVetsTitle => 'لا توجد عيادات مفضلة بعد';

  @override
  String get favoritesNoVetsMessage =>
      'اضغط على أيقونة القلب في أي عيادة لحفظها هنا للوصول السريع.';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileEditTooltip => 'تعديل الملف الشخصي';

  @override
  String get profileSignOut => 'تسجيل الخروج';

  @override
  String get profileSignIn => 'تسجيل الدخول';

  @override
  String get profileCreateAccount => 'إنشاء حساب';

  @override
  String get profileSettingsHeader => 'الإعدادات';

  @override
  String get profileNotificationsTitle => 'الإشعارات';

  @override
  String get profileNotificationsSubtitle => 'قريبًا في مرحلة لاحقة';

  @override
  String get profileNotificationsSnack =>
      'الإشعارات مخطط لها في المرحلة الثالثة';

  @override
  String get profileAppearanceTitle => 'المظهر';

  @override
  String get profileLocationTitle => 'الموقع';

  @override
  String profileLocationGps(String label) {
    return 'باستخدام GPS · $label';
  }

  @override
  String profileLocationFallback(String label) {
    return 'موقع افتراضي · $label';
  }

  @override
  String get profileLocationDetecting => 'جارٍ التحديد...';

  @override
  String get profileLocationRefreshedSnack => 'تم تحديث الموقع';

  @override
  String get profilePartnerDashboardTitle => 'لوحة الشريك';

  @override
  String get profilePartnerDashboardSubtitle => 'إدارة عياداتك ومتاجرك';

  @override
  String get profileBecomePartnerTitle => 'أضف عيادتك أو متجرك';

  @override
  String get profileBecomePartnerSubtitle =>
      'كن شريكًا لتقديم إعلاناتك للمراجعة';

  @override
  String get profileSignInPartnerPrompt =>
      'سجّل الدخول أو أنشئ حسابًا كشريك لإضافة عيادتك أو متجرك.';

  @override
  String get profileHelpContact => 'المساعدة والتواصل';

  @override
  String profileTagline(String appName, String status) {
    return '$appName · المرحلة الثانية\n$status';
  }

  @override
  String get profileSignedInStatus => 'تم تسجيل الدخول';

  @override
  String get profileGuestStatus => 'تصفح كزائر';

  @override
  String get profileBecomePartnerDialogTitle => 'أضف عيادتك أو متجرك';

  @override
  String get profileBecomePartnerDialogContent =>
      'سيتم ترقية حسابك إلى حساب شريك لتتمكن من تقديم إعلانات للمراجعة. لن يراها العملاء إلا بعد الموافقة عليها.';

  @override
  String get profileBecomePartnerConfirm => 'الانضمام كشريك';

  @override
  String get profileSignOutDialogTitle => 'تسجيل الخروج';

  @override
  String get profileSignOutDialogContent =>
      'يمكنك الاستمرار بالتصفح كزائر على هذا الجهاز.';

  @override
  String get profileSignOutSnack => 'تم تسجيل الخروج';

  @override
  String get profileEditDialogTitle => 'تعديل الملف الشخصي';

  @override
  String get profileEditNameLabel => 'الاسم';

  @override
  String get profileEditPhoneLabel => 'رقم الهاتف (اختياري)';

  @override
  String get profileUpdatedSnack => 'تم تحديث الملف الشخصي';

  @override
  String profileUpdateFailedSnack(String error) {
    return 'تعذّر تحديث الملف الشخصي: $error';
  }

  @override
  String get profileLanguageTitle => 'اللغة';

  @override
  String get profileLanguageSystem => 'لغة النظام';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageArabic => 'العربية';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeSystem => 'النظام';

  @override
  String get errorConnectionTimeout =>
      'انتهت مهلة الاتصال. تحقق من شبكتك وحاول مرة أخرى.';

  @override
  String get errorCannotReachServer =>
      'تعذّر الوصول إلى خوادم Petly. تأكد من أن الخدمة تعمل.';

  @override
  String errorGenericWithCode(int code) {
    return 'حدث خطأ ما ($code)';
  }

  @override
  String get errorUnexpectedNetwork => 'حدث خطأ غير متوقع في الشبكة';

  @override
  String get errorGeneric => 'حدث خطأ ما. يُرجى المحاولة مرة أخرى.';

  @override
  String get errorYoureOffline => 'أنت غير متصل بالإنترنت';

  @override
  String get errorSomethingWentWrongTitle => 'حدث خطأ ما';

  @override
  String get offlineBannerText => 'لا يوجد اتصال بالإنترنت';
}
