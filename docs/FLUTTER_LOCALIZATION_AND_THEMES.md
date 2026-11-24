# Usayd Academy — Flutter Localization & Theme Architecture

Documenting the implementation of **USYD-T0077** for the `usayd-flutter` repository.

---

## 1. Architecture Overview & Canon References

The localization and theming system for Usayd Academy mobile app adheres strictly to:
- `05_requirements/LOCALIZATION_AR_EN.md`: Bilingual requirements, separation of preferences, and Quranic invariant rules.
- `04_flows/02_locale_independence.mmd`: Formal flow showing student settings language changes updating user locale and root directionality while strictly preserving selected market country, currency, and timezone.
- `02_design_system/tokens.color.v0.4.json`: Parchment light and night dark color themes.

---

## 2. Separation of Preferences Principle

As specified in `LOCALIZATION_AR_EN.md` and `02_locale_independence.mmd`:
- `locale` = `ar` or `en` (language).
- `marketCountry` = e.g., `'EG'`, `'SA'`, `'GB'`, `'AE'`, `'KW'`.
- `currency` = e.g., `'EGP'`, `'SAR'`, `'GBP'`, `'AED'`, `'KWD'`.
- `timezone` = e.g., `'Africa/Cairo'`, `'Asia/Riyadh'`, `'Europe/London'`.

**Strict Invariant**:
Changing UI language from Arabic (`ar`) to English (`en`) or vice-versa updates the UI strings and root Directionality (`rtl` $\leftrightarrow$ `ltr`) but **never alters** the student's market, currency, or timezone.

Implemented in `lib/core/config/user_preferences.dart` and verified by `test/unit/localization_independence_test.dart`.

---

## 3. Sacred Quranic Invariant Policy

As mandated by Usayd Academy governance:
- **Canonical Arabic Mushaf**: The Quran text is strictly preserved in its authentic Uthmani script with full diacritics and is **never machine-translated or paraphrased in place** when switching interface language.
- When an English learner uses the app, approved translations and tafsir are presented in dedicated companion cards with citations and license notes, never replacing the Arabic Quran text.
- Brand name remains **«أُسَيْد»** with full tashkeel in Arabic contexts and **Usayd** in Latin contexts.

---

## 4. Directionality & Localization (`UsaydLocalizations`)

- Default language: **Arabic (`ar`)** with Right-to-Left layout (`TextDirection.rtl`).
- Supported language: **English (`en`)** with Left-to-Right layout (`TextDirection.ltr`).
- Directionality switches at the root `Directionality` widget.
- Navigation chevrons and directional arrows mirror according to reading direction; brand marks, mushaf icons, and audio play controls remain canonical and do not mirror.

---

## 5. Light & Dark Themes

- Dynamic theme mode switching (`ThemeMode.light` $\leftrightarrow$ `ThemeMode.dark`).
- Parchment light palette: `bgPage = #FBF7EE`, `bgBrand = #0F2529`, `act = #0F2529`.
- Night dark palette: `bgPage = #0A1B1E`, `bgBrand = #06141A`, `act = #E8B04B`.
- Integrated seamlessly with `UsaydModeTheme` across all three adaptive modes (Kids, Pro, Simple).

---

## 6. Verification & Test Evidence

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```
- Total test coverage: 37 tests passing across:
  - `localization_independence_test.dart`
  - `localization_widget_test.dart`
  - `theme_tokens_test.dart`
  - `theme_widget_test.dart`
  - `assets_test.dart`
  - `flavor_config_test.dart`
  - `interface_mode_test.dart`
  - `app_widget_test.dart`
  - `mode_toggle_test.dart`
