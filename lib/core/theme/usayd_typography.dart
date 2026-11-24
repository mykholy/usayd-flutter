import 'package:flutter/material.dart';

/// Typography tokens for Usayd Academy (أكاديمية أُسَيْد)
/// Source: `tokens.json` (typography)
///
/// Guidelines:
/// - Display & Section Headings: `Reem Kufi` (Kufic solemnity and elegance)
/// - Body, Subheadings, UI & Quran Translations: `IBM Plex Sans Arabic`
/// - Mushaf Arabic Text: preserved independently with dedicated Quranic font rules.
abstract final class UsaydTypography {
  static const String fontFamilyHeading = 'Reem Kufi';
  static const String fontFamilyBody = 'IBM Plex Sans Arabic';

  static const List<String> fallbackFamilies = [
    'Noto Sans Arabic',
    'Segoe UI',
    'Arial',
    'sans-serif',
  ];

  /// Display Large: 56px / 68px line-height / SemiBold 600
  static const TextStyle displayL = TextStyle(
    fontFamily: fontFamilyHeading,
    fontFamilyFallback: fallbackFamilies,
    fontSize: 56.0,
    height: 68.0 / 56.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  /// Display Medium: 44px / 58px line-height / SemiBold 600
  static const TextStyle displayM = TextStyle(
    fontFamily: fontFamilyHeading,
    fontFamilyFallback: fallbackFamilies,
    fontSize: 44.0,
    height: 58.0 / 44.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  /// Display Small: 36px / 48px line-height / SemiBold 600
  static const TextStyle displayS = TextStyle(
    fontFamily: fontFamilyHeading,
    fontFamilyFallback: fallbackFamilies,
    fontSize: 36.0,
    height: 48.0 / 36.0,
    fontWeight: FontWeight.w600,
  );

  /// Heading Large: 26px / 38px line-height / Medium 500
  static const TextStyle headingL = TextStyle(
    fontFamily: fontFamilyHeading,
    fontFamilyFallback: fallbackFamilies,
    fontSize: 26.0,
    height: 38.0 / 26.0,
    fontWeight: FontWeight.w500,
  );

  /// Heading Medium: 20px / 32px line-height / SemiBold 600
  static const TextStyle headingM = TextStyle(
    fontFamily: fontFamilyBody,
    fontFamilyFallback: fallbackFamilies,
    fontSize: 20.0,
    height: 32.0 / 20.0,
    fontWeight: FontWeight.w600,
  );

  /// Heading Small: 17px / 28px line-height / SemiBold 600
  static const TextStyle headingS = TextStyle(
    fontFamily: fontFamilyBody,
    fontFamilyFallback: fallbackFamilies,
    fontSize: 17.0,
    height: 28.0 / 17.0,
    fontWeight: FontWeight.w600,
  );

  /// Body Large: 19px / 33px line-height / Regular 400
  static const TextStyle bodyL = TextStyle(
    fontFamily: fontFamilyBody,
    fontFamilyFallback: fallbackFamilies,
    fontSize: 19.0,
    height: 33.0 / 19.0,
    fontWeight: FontWeight.w400,
  );

  /// Body Medium: 17px / 30px line-height / Regular 400
  static const TextStyle bodyM = TextStyle(
    fontFamily: fontFamilyBody,
    fontFamilyFallback: fallbackFamilies,
    fontSize: 17.0,
    height: 30.0 / 17.0,
    fontWeight: FontWeight.w400,
  );

  /// Body Small: 14px / 24px line-height / Regular 400
  static const TextStyle bodyS = TextStyle(
    fontFamily: fontFamilyBody,
    fontFamilyFallback: fallbackFamilies,
    fontSize: 14.0,
    height: 24.0 / 14.0,
    fontWeight: FontWeight.w400,
  );

  /// Caption: 12px / 20px line-height / Regular 400
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamilyBody,
    fontFamilyFallback: fallbackFamilies,
    fontSize: 12.0,
    height: 20.0 / 12.0,
    fontWeight: FontWeight.w400,
  );

  /// Generate Material TextTheme with primary text color
  static TextTheme createTextTheme(Color primaryText, Color mutedText) {
    return TextTheme(
      displayLarge: displayL.copyWith(color: primaryText),
      displayMedium: displayM.copyWith(color: primaryText),
      displaySmall: displayS.copyWith(color: primaryText),
      headlineLarge: headingL.copyWith(color: primaryText),
      headlineMedium: headingM.copyWith(color: primaryText),
      headlineSmall: headingS.copyWith(color: primaryText),
      bodyLarge: bodyL.copyWith(color: primaryText),
      bodyMedium: bodyM.copyWith(color: primaryText),
      bodySmall: bodyS.copyWith(color: mutedText),
      labelSmall: caption.copyWith(color: mutedText),
    );
  }
}
