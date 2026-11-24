import 'package:flutter/material.dart';
import 'app_locale.dart';

/// Bilingual localized strings dictionary for Usayd Academy
/// Conforms to `LOCALIZATION_AR_EN.md` string namespaces
class UsaydLocalizations {
  final AppLocale locale;

  const UsaydLocalizations(this.locale);

  static const LocalizationsDelegate<UsaydLocalizations> delegate =
      _UsaydLocalizationsDelegate();

  static UsaydLocalizations of(BuildContext context) {
    return Localizations.of<UsaydLocalizations>(context, UsaydLocalizations) ??
        const UsaydLocalizations(AppLocale.ar);
  }

  bool get isRtl => locale.isRtl;

  // Common & Brand
  String get brandName =>
      locale == AppLocale.ar ? 'أكاديمية أُسَيْد' : 'Usayd Academy';
  String get sacredNameWithTashkeel => 'أُسَيْد';
  String get tagline => locale == AppLocale.ar
      ? '«اقرأ بصوتٍ تدنو له الملائكة»'
      : '“Recite with a voice that angels draw near to hear”';

  // Navigation & Shell
  String get home => locale == AppLocale.ar ? 'الرئيسية' : 'Home';
  String get lessons => locale == AppLocale.ar ? 'الدروس' : 'Lessons';
  String get practice =>
      locale == AppLocale.ar ? 'التلاوة والحفظ' : 'Recite & Memorize';
  String get progress => locale == AppLocale.ar ? 'التقدم' : 'Progress';
  String get profile => locale == AppLocale.ar ? 'الملف الشخصي' : 'Profile';
  String get settings => locale == AppLocale.ar ? 'الإعدادات' : 'Settings';
  String get help => locale == AppLocale.ar ? 'المساعدة' : 'Help';

  // Settings & Localization
  String get language =>
      locale == AppLocale.ar ? 'لغة الواجهة' : 'Interface Language';
  String get arabic => locale == AppLocale.ar ? 'العربية' : 'Arabic';
  String get english => locale == AppLocale.ar ? 'الإنجليزية' : 'English';

  // Theme Modes
  String get themeMode => locale == AppLocale.ar ? 'المظهر' : 'Theme';
  String get themeLight =>
      locale == AppLocale.ar ? 'فاتح (ورقي)' : 'Light (Parchment)';
  String get themeDark =>
      locale == AppLocale.ar ? 'داكن (ليلي)' : 'Dark (Night)';
  String get themeSystem =>
      locale == AppLocale.ar ? 'تلقائي (حسب النظام)' : 'System';

  // Age-Adaptive Modes
  String get adaptiveModeTitle => locale == AppLocale.ar
      ? 'نمط الواجهة التكيفي:'
      : 'Adaptive Interface Mode:';
  String get activeMode =>
      locale == AppLocale.ar ? 'النمط النشط:' : 'Active Mode:';
  String get targetAudience =>
      locale == AppLocale.ar ? 'الفئة المستهدفة:' : 'Target Audience:';
  String get buttonHeight =>
      locale == AppLocale.ar ? 'ارتفاع الأزرار:' : 'Button Height:';
  String get cardRadius =>
      locale == AppLocale.ar ? 'زاوية البطاقة:' : 'Card Radius:';

  // Market & Timezone Independence
  String get market => locale == AppLocale.ar ? 'السوق' : 'Market';
  String get currency => locale == AppLocale.ar ? 'العملة' : 'Currency';
  String get timezone =>
      locale == AppLocale.ar ? 'المنطقة الزمنية' : 'Timezone';
  String get localeIndependenceNote => locale == AppLocale.ar
      ? 'تغيير اللغة مستقل تماماً عن السوق والعملة والمنطقة الزمنية.'
      : 'Language preference is strictly independent of market, currency, and timezone.';

  // Sacred Quran Policy
  String get quranPolicy => locale == AppLocale.ar
      ? 'النص القرآني محفوظ برسمه العثماني الأصيل ولا يتغير أو يترجم آلياً بتغيير لغة الواجهة.'
      : 'The Quranic text is preserved in authentic Uthmani script and is never altered or machine-translated when switching UI language.';
}

class _UsaydLocalizationsDelegate
    extends LocalizationsDelegate<UsaydLocalizations> {
  const _UsaydLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode.toLowerCase());
  }

  @override
  Future<UsaydLocalizations> load(Locale locale) async {
    return UsaydLocalizations(AppLocale.fromLanguageCode(locale.languageCode));
  }

  @override
  bool shouldReload(_UsaydLocalizationsDelegate old) => false;
}
