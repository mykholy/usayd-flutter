import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';
import 'package:usayd_flutter/core/config/user_preferences.dart';
import 'package:usayd_flutter/core/localization/app_locale.dart';
import 'package:usayd_flutter/core/localization/usayd_localizations.dart';

void main() {
  group(
    'Localization & Preference Independence Tests (02_locale_independence.mmd)',
    () {
      test(
        'Locale switching strictly preserves market, currency, and timezone',
        () {
          const initial = UserPreferences(
            locale: AppLocale.ar,
            marketCountry: 'GB',
            currency: 'GBP',
            timezone: 'Europe/London',
            themeMode: ThemeMode.light,
            interfaceMode: InterfaceMode.pro,
          );

          // Change UI language from Arabic to English
          final updated = initial.copyWith(locale: AppLocale.en);

          expect(updated.locale, AppLocale.en);
          expect(updated.textDirection, TextDirection.ltr);

          // Crucial verification: market, currency, timezone remain unmodified!
          expect(updated.marketCountry, 'GB');
          expect(updated.currency, 'GBP');
          expect(updated.timezone, 'Europe/London');
          expect(updated.themeMode, ThemeMode.light);
          expect(updated.interfaceMode, InterfaceMode.pro);
        },
      );

      test('Market change preserves user language locale preference', () {
        const initial = UserPreferences(
          locale: AppLocale.ar,
          marketCountry: 'EG',
          currency: 'EGP',
          timezone: 'Africa/Cairo',
        );

        // Student changes market to Saudi Arabia
        final updated = initial.copyWith(
          marketCountry: 'SA',
          currency: 'SAR',
          timezone: 'Asia/Riyadh',
        );

        expect(updated.locale, AppLocale.ar);
        expect(updated.marketCountry, 'SA');
        expect(updated.currency, 'SAR');
        expect(updated.timezone, 'Asia/Riyadh');
      });

      test('AppLocale defines correct text directionality', () {
        expect(AppLocale.ar.textDirection, TextDirection.rtl);
        expect(AppLocale.ar.isRtl, isTrue);

        expect(AppLocale.en.textDirection, TextDirection.ltr);
        expect(AppLocale.en.isRtl, isFalse);
      });

      test('UsaydLocalizations dictionary parity for Arabic and English', () {
        const ar = UsaydLocalizations(AppLocale.ar);
        const en = UsaydLocalizations(AppLocale.en);

        // Brand & Sacred names
        expect(ar.brandName, 'أكاديمية أُسَيْد');
        expect(en.brandName, 'Usayd Academy');
        expect(ar.sacredNameWithTashkeel, 'أُسَيْد');
        expect(en.sacredNameWithTashkeel, 'أُسَيْد');

        // Taglines
        expect(ar.tagline, contains('الملائكة'));
        expect(en.tagline, contains('angels'));

        // Navigation & Settings
        expect(ar.home.isNotEmpty, isTrue);
        expect(en.home.isNotEmpty, isTrue);
        expect(ar.lessons.isNotEmpty, isTrue);
        expect(en.lessons.isNotEmpty, isTrue);
        expect(ar.themeLight.isNotEmpty, isTrue);
        expect(en.themeDark.isNotEmpty, isTrue);

        // Quran Policy Invariant
        expect(ar.quranPolicy, contains('العثماني'));
        expect(en.quranPolicy, contains('Uthmani'));
      });
    },
  );
}
