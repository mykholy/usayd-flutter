import 'package:flutter/material.dart';

/// Supported application locales for Usayd Academy
/// Source: `LOCALIZATION_AR_EN.md`
enum AppLocale {
  ar(
    locale: Locale('ar'),
    textDirection: TextDirection.rtl,
    displayNameArabic: 'العربية',
    displayNameEnglish: 'Arabic',
  ),
  en(
    locale: Locale('en'),
    textDirection: TextDirection.ltr,
    displayNameArabic: 'الإنجليزية',
    displayNameEnglish: 'English',
  );

  final Locale locale;
  final TextDirection textDirection;
  final String displayNameArabic;
  final String displayNameEnglish;

  const AppLocale({
    required this.locale,
    required this.textDirection,
    required this.displayNameArabic,
    required this.displayNameEnglish,
  });

  bool get isRtl => textDirection == TextDirection.rtl;

  static AppLocale fromLanguageCode(String code) {
    return code.toLowerCase() == 'en' ? AppLocale.en : AppLocale.ar;
  }
}
