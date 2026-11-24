import 'package:flutter/material.dart';
import '../config/interface_mode.dart';

/// Theme extension for Age-Adaptive UI mode parameters
/// Source: `02_design_system/AGE_ADAPTIVE_UI.md`
class UsaydModeTheme extends ThemeExtension<UsaydModeTheme> {
  final InterfaceMode mode;
  final double bodyTextSize;
  final double buttonHeight;
  final double cardRadius;
  final double cardBorderWidth;
  final int tabCount;
  final bool hasMotion;
  final bool hasHeaderPattern;
  final double minTouchTarget;

  const UsaydModeTheme({
    required this.mode,
    required this.bodyTextSize,
    required this.buttonHeight,
    required this.cardRadius,
    required this.cardBorderWidth,
    required this.tabCount,
    required this.hasMotion,
    required this.hasHeaderPattern,
    required this.minTouchTarget,
  });

  /// Factory for Kids Mode (6–12 years)
  /// - Gamified, friendly large targets (56px)
  /// - Card radius 24px
  /// - 4 primary tabs (Mission, Path, Stars, Me)
  /// - Gentle animations, celebration sounds optional/off by default
  factory UsaydModeTheme.kids() => const UsaydModeTheme(
    mode: InterfaceMode.kids,
    bodyTextSize: 16.0,
    buttonHeight: 56.0,
    cardRadius: 24.0,
    cardBorderWidth: 0.0,
    tabCount: 4,
    hasMotion: true,
    hasHeaderPattern: true,
    minTouchTarget: 56.0,
  );

  /// Factory for Professional Mode (13–59 years)
  /// - Balanced density, full tajweed tools
  /// - Button height 48px, card radius 20px
  /// - 5 tabs, standard motion
  factory UsaydModeTheme.pro() => const UsaydModeTheme(
    mode: InterfaceMode.pro,
    bodyTextSize: 15.5,
    buttonHeight: 48.0,
    cardRadius: 20.0,
    cardBorderWidth: 0.0,
    tabCount: 5,
    hasMotion: true,
    hasHeaderPattern: true,
    minTouchTarget: 44.0,
  );

  /// Factory for Simple Mode (60+ years)
  /// - High legibility (19.5px body text)
  /// - Button height 60px, touch targets ≥ 60px
  /// - Card radius 20px with explicit 1.5px high-contrast border
  /// - 3 tabs (Today, Lessons, Help), zero motion (motion = false)
  factory UsaydModeTheme.simple() => const UsaydModeTheme(
    mode: InterfaceMode.simple,
    bodyTextSize: 19.5,
    buttonHeight: 60.0,
    cardRadius: 20.0,
    cardBorderWidth: 1.5,
    tabCount: 3,
    hasMotion: false,
    hasHeaderPattern: false,
    minTouchTarget: 60.0,
  );

  /// Helper factory based on mode enum
  factory UsaydModeTheme.forMode(InterfaceMode mode) {
    switch (mode) {
      case InterfaceMode.kids:
        return UsaydModeTheme.kids();
      case InterfaceMode.pro:
        return UsaydModeTheme.pro();
      case InterfaceMode.simple:
        return UsaydModeTheme.simple();
    }
  }

  @override
  UsaydModeTheme copyWith({
    InterfaceMode? mode,
    double? bodyTextSize,
    double? buttonHeight,
    double? cardRadius,
    double? cardBorderWidth,
    int? tabCount,
    bool? hasMotion,
    bool? hasHeaderPattern,
    double? minTouchTarget,
  }) {
    return UsaydModeTheme(
      mode: mode ?? this.mode,
      bodyTextSize: bodyTextSize ?? this.bodyTextSize,
      buttonHeight: buttonHeight ?? this.buttonHeight,
      cardRadius: cardRadius ?? this.cardRadius,
      cardBorderWidth: cardBorderWidth ?? this.cardBorderWidth,
      tabCount: tabCount ?? this.tabCount,
      hasMotion: hasMotion ?? this.hasMotion,
      hasHeaderPattern: hasHeaderPattern ?? this.hasHeaderPattern,
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
    );
  }

  @override
  UsaydModeTheme lerp(ThemeExtension<UsaydModeTheme>? other, double t) {
    if (other is! UsaydModeTheme) return this;
    return UsaydModeTheme(
      mode: t < 0.5 ? mode : other.mode,
      bodyTextSize: bodyTextSize + (other.bodyTextSize - bodyTextSize) * t,
      buttonHeight: buttonHeight + (other.buttonHeight - buttonHeight) * t,
      cardRadius: cardRadius + (other.cardRadius - cardRadius) * t,
      cardBorderWidth:
          cardBorderWidth + (other.cardBorderWidth - cardBorderWidth) * t,
      tabCount: t < 0.5 ? tabCount : other.tabCount,
      hasMotion: t < 0.5 ? hasMotion : other.hasMotion,
      hasHeaderPattern: t < 0.5 ? hasHeaderPattern : other.hasHeaderPattern,
      minTouchTarget:
          minTouchTarget + (other.minTouchTarget - minTouchTarget) * t,
    );
  }
}
