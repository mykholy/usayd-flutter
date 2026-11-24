import 'package:flutter/material.dart';
import '../config/interface_mode.dart';
import '../localization/app_locale.dart';

/// User preferences model enforcing strict separation of preferences:
/// `locale` (language) is strictly independent of `marketCountry`, `currency`, and `timezone`.
/// Source: `LOCALIZATION_AR_EN.md` & `02_locale_independence.mmd`
@immutable
class UserPreferences {
  final AppLocale locale;
  final ThemeMode themeMode;
  final InterfaceMode interfaceMode;
  final String marketCountry;
  final String currency;
  final String timezone;

  const UserPreferences({
    this.locale = AppLocale.ar,
    this.themeMode = ThemeMode.light,
    this.interfaceMode = InterfaceMode.pro,
    this.marketCountry = 'EG',
    this.currency = 'EGP',
    this.timezone = 'Africa/Cairo',
  });

  TextDirection get textDirection => locale.textDirection;
  bool get isRtl => locale.isRtl;

  /// Factory for guest / default initial setup
  factory UserPreferences.defaults() => const UserPreferences();

  /// Creates a copy with the given fields replaced by the new values.
  /// When updating locale, marketCountry, currency, and timezone are GUARANTEED
  /// to remain unchanged unless explicitly provided.
  UserPreferences copyWith({
    AppLocale? locale,
    ThemeMode? themeMode,
    InterfaceMode? interfaceMode,
    String? marketCountry,
    String? currency,
    String? timezone,
  }) {
    return UserPreferences(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      interfaceMode: interfaceMode ?? this.interfaceMode,
      marketCountry: marketCountry ?? this.marketCountry,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences &&
        other.locale == locale &&
        other.themeMode == themeMode &&
        other.interfaceMode == interfaceMode &&
        other.marketCountry == marketCountry &&
        other.currency == currency &&
        other.timezone == timezone;
  }

  @override
  int get hashCode => Object.hash(
    locale,
    themeMode,
    interfaceMode,
    marketCountry,
    currency,
    timezone,
  );
}
