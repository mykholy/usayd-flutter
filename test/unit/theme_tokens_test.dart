import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';
import 'package:usayd_flutter/core/theme/usayd_colors.dart';
import 'package:usayd_flutter/core/theme/usayd_mode_theme.dart';
import 'package:usayd_flutter/core/theme/usayd_radii.dart';
import 'package:usayd_flutter/core/theme/usayd_spacing.dart';
import 'package:usayd_flutter/core/theme/usayd_typography.dart';

void main() {
  group('UsaydColorScheme Token Tests', () {
    test('Light color scheme matches tokens.color.v0.4.json values', () {
      const colors = UsaydColorScheme.light;
      expect(colors.bgPage, const Color(0xFFFBF7EE));
      expect(colors.bgRaised, const Color(0xFFFFFDF8));
      expect(colors.bgBrand, const Color(0xFF0F2529));
      expect(colors.tx, const Color(0xFF1A1814));
      expect(colors.lamp, const Color(0xFFE8B04B));
      expect(colors.brass, const Color(0xFF8A5F12));
      expect(colors.ok, const Color(0xFF2A6448));
      expect(colors.err, const Color(0xFFA33725));
    });

    test('Dark color scheme matches tokens.color.v0.4.json values', () {
      const colors = UsaydColorScheme.dark;
      expect(colors.bgPage, const Color(0xFF0A1B1E));
      expect(colors.bgRaised, const Color(0xFF11282C));
      expect(colors.bgBrand, const Color(0xFF06141A));
      expect(colors.tx, const Color(0xFFF4EDDF));
      expect(colors.lamp, const Color(0xFFE8B04B));
      expect(colors.line, const Color(0xFF203B40));
      expect(colors.ok, const Color(0xFF7DCBA3));
      expect(colors.err, const Color(0xFFF29C87));
    });

    test(
      'Lamp gold is paired with dark contrast text and brass is accessible on parchment',
      () {
        const light = UsaydColorScheme.light;
        const dark = UsaydColorScheme.dark;

        // On lamp color must be dark text for readability
        expect(light.onLamp, const Color(0xFF1A1814));
        expect(dark.onLamp, const Color(0xFF14120E));

        // Brass is used for accessible text on light backgrounds
        expect(light.brass, const Color(0xFF8A5F12));
      },
    );

    test('UsaydColorScheme copyWith preserves unchanged values', () {
      const light = UsaydColorScheme.light;
      final modified = light.copyWith(bgPage: Colors.white);
      expect(modified.bgPage, Colors.white);
      expect(modified.bgRaised, light.bgRaised);
      expect(modified.tx, light.tx);
      expect(modified.lamp, light.lamp);
    });

    test('UsaydColorScheme lerp smoothly interpolates colors', () {
      const light = UsaydColorScheme.light;
      const dark = UsaydColorScheme.dark;
      final mid = light.lerp(dark, 0.5);

      expect(mid.bgPage, isNotNull);
      expect(mid.bgPage, isNot(light.bgPage));
      expect(mid.bgPage, isNot(dark.bgPage));
    });
  });

  group('UsaydSpacing Scale Tests', () {
    test('Spacing tokens match geometric progression', () {
      expect(UsaydSpacing.xxs, 2.0);
      expect(UsaydSpacing.xs, 4.0);
      expect(UsaydSpacing.sm, 8.0);
      expect(UsaydSpacing.smPlus, 12.0);
      expect(UsaydSpacing.md, 16.0);
      expect(UsaydSpacing.mdPlus, 20.0);
      expect(UsaydSpacing.lg, 24.0);
      expect(UsaydSpacing.xl, 32.0);
      expect(UsaydSpacing.xlPlus, 40.0);
      expect(UsaydSpacing.xxl, 48.0);
      expect(UsaydSpacing.xxxl, 64.0);
      expect(UsaydSpacing.xxxxl, 80.0);
      expect(UsaydSpacing.xxxxxl, 96.0);
    });
  });

  group('UsaydRadii Tokens Tests', () {
    test('Corner radius tokens match tokens.json', () {
      expect(UsaydRadii.none, BorderRadius.zero);
      expect(UsaydRadii.xs.topLeft.x, 4.0);
      expect(UsaydRadii.sm.topLeft.x, 6.0);
      expect(UsaydRadii.md.topLeft.x, 14.0);
      expect(UsaydRadii.lg.topLeft.x, 20.0);
      expect(UsaydRadii.xl.topLeft.x, 28.0);
      expect(UsaydRadii.full.topLeft.x, 999.0);
      expect(UsaydRadii.arch.topLeft.x, 999.0);
      expect(UsaydRadii.arch.bottomLeft.x, 0.0);
    });
  });

  group('UsaydTypography Tokens Tests', () {
    test('Heading and body font families are correctly defined', () {
      expect(UsaydTypography.fontFamilyHeading, 'Reem Kufi');
      expect(UsaydTypography.fontFamilyBody, 'IBM Plex Sans Arabic');
      expect(UsaydTypography.fallbackFamilies, contains('Noto Sans Arabic'));
    });

    test('Type scale font sizes match tokens.json specification', () {
      expect(UsaydTypography.displayL.fontSize, 56.0);
      expect(UsaydTypography.displayM.fontSize, 44.0);
      expect(UsaydTypography.displayS.fontSize, 36.0);
      expect(UsaydTypography.headingL.fontSize, 26.0);
      expect(UsaydTypography.headingM.fontSize, 20.0);
      expect(UsaydTypography.headingS.fontSize, 17.0);
      expect(UsaydTypography.bodyL.fontSize, 19.0);
      expect(UsaydTypography.bodyM.fontSize, 17.0);
      expect(UsaydTypography.bodyS.fontSize, 14.0);
      expect(UsaydTypography.caption.fontSize, 12.0);
    });
  });

  group('UsaydModeTheme Age-Adaptive Tests', () {
    test('Kids mode conforms to AGE_ADAPTIVE_UI.md spec', () {
      final kids = UsaydModeTheme.kids();
      expect(kids.mode, InterfaceMode.kids);
      expect(kids.bodyTextSize, 16.0);
      expect(kids.buttonHeight, 56.0);
      expect(kids.cardRadius, 24.0);
      expect(kids.cardBorderWidth, 0.0);
      expect(kids.tabCount, 4);
      expect(kids.hasMotion, isTrue);
      expect(kids.hasHeaderPattern, isTrue);
      expect(kids.minTouchTarget, 56.0);
    });

    test('Professional mode conforms to AGE_ADAPTIVE_UI.md spec', () {
      final pro = UsaydModeTheme.pro();
      expect(pro.mode, InterfaceMode.pro);
      expect(pro.bodyTextSize, 15.5);
      expect(pro.buttonHeight, 48.0);
      expect(pro.cardRadius, 20.0);
      expect(pro.cardBorderWidth, 0.0);
      expect(pro.tabCount, 5);
      expect(pro.hasMotion, isTrue);
      expect(pro.hasHeaderPattern, isTrue);
      expect(pro.minTouchTarget, 44.0);
    });

    test('Simple mode conforms to AGE_ADAPTIVE_UI.md spec for seniors', () {
      final simple = UsaydModeTheme.simple();
      expect(simple.mode, InterfaceMode.simple);
      expect(simple.bodyTextSize, 19.5);
      expect(simple.buttonHeight, 60.0);
      expect(simple.cardRadius, 20.0);
      expect(simple.cardBorderWidth, 1.5); // Explicit high-contrast border
      expect(simple.tabCount, 3); // Today, Lessons, Help
      expect(simple.hasMotion, isFalse); // Motion disabled for legibility
      expect(simple.hasHeaderPattern, isFalse); // Plain night, no pattern
      expect(simple.minTouchTarget, 60.0); // Touch targets >= 60px
    });

    test('forMode helper resolves all three interface modes', () {
      expect(
        UsaydModeTheme.forMode(InterfaceMode.kids).mode,
        InterfaceMode.kids,
      );
      expect(UsaydModeTheme.forMode(InterfaceMode.pro).mode, InterfaceMode.pro);
      expect(
        UsaydModeTheme.forMode(InterfaceMode.simple).mode,
        InterfaceMode.simple,
      );
    });
  });
}
