import 'package:flutter/material.dart';
import '../config/interface_mode.dart';
import 'usayd_colors.dart';
import 'usayd_mode_theme.dart';
import 'usayd_radii.dart';
import 'usayd_spacing.dart';
import 'usayd_typography.dart';

/// Complete ThemeData assembler for Usayd Academy
/// Combines UsaydColorScheme, UsaydTypography, UsaydRadii, UsaydSpacing, and UsaydModeTheme
abstract final class UsaydTheme {
  /// Assemble light ThemeData based on selected InterfaceMode
  static ThemeData light([InterfaceMode mode = InterfaceMode.pro]) {
    const colors = UsaydColorScheme.light;
    final modeTheme = UsaydModeTheme.forMode(mode);
    final textTheme = UsaydTypography.createTextTheme(colors.tx, colors.tx2);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: colors.bgBrand,
      scaffoldBackgroundColor: colors.bgPage,
      colorScheme: ColorScheme.light(
        primary: colors.act,
        onPrimary: colors.onAct,
        secondary: colors.lamp,
        onSecondary: colors.onLamp,
        surface: colors.bgRaised,
        onSurface: colors.tx,
        error: colors.err,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: colors.bgRaised,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(modeTheme.cardRadius),
          side: modeTheme.cardBorderWidth > 0
              ? BorderSide(
                  color: colors.lineStrong,
                  width: modeTheme.cardBorderWidth,
                )
              : BorderSide(color: colors.line),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.act,
          foregroundColor: colors.onAct,
          elevation: 0,
          minimumSize: Size(double.infinity, modeTheme.buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: UsaydRadii.full),
          textStyle: UsaydTypography.headingS.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bgBrand,
        foregroundColor: colors.txOnBrand,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: UsaydTypography.headingM.copyWith(
          color: colors.txOnBrand,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.line,
        thickness: 1.0,
        space: UsaydSpacing.md,
      ),
      extensions: [colors, modeTheme],
    );
  }

  /// Assemble dark ThemeData based on selected InterfaceMode
  static ThemeData dark([InterfaceMode mode = InterfaceMode.pro]) {
    const colors = UsaydColorScheme.dark;
    final modeTheme = UsaydModeTheme.forMode(mode);
    final textTheme = UsaydTypography.createTextTheme(colors.tx, colors.tx2);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: colors.act,
      scaffoldBackgroundColor: colors.bgPage,
      colorScheme: ColorScheme.dark(
        primary: colors.act,
        onPrimary: colors.onAct,
        secondary: colors.lamp,
        onSecondary: colors.onLamp,
        surface: colors.bgRaised,
        onSurface: colors.tx,
        error: colors.err,
        onError: colors.onAct,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: colors.bgRaised,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(modeTheme.cardRadius),
          side: modeTheme.cardBorderWidth > 0
              ? BorderSide(
                  color: colors.lineStrong,
                  width: modeTheme.cardBorderWidth,
                )
              : BorderSide(color: colors.line),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.act,
          foregroundColor: colors.onAct,
          elevation: 0,
          minimumSize: Size(double.infinity, modeTheme.buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: UsaydRadii.full),
          textStyle: UsaydTypography.headingS.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onAct,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bgPage,
        foregroundColor: colors.tx,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: UsaydTypography.headingM.copyWith(color: colors.tx),
      ),
      dividerTheme: DividerThemeData(
        color: colors.line,
        thickness: 1.0,
        space: UsaydSpacing.md,
      ),
      extensions: [colors, modeTheme],
    );
  }
}
