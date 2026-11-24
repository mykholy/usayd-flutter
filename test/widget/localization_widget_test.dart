import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/app.dart';
import 'package:usayd_flutter/core/config/flavor_config.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';
import 'package:usayd_flutter/core/config/user_preferences.dart';
import 'package:usayd_flutter/core/localization/app_locale.dart';
import 'package:usayd_flutter/core/theme/usayd_colors.dart';

void main() {
  setUpAll(() {
    FlavorConfig.init(
      flavor: AppFlavor.dev,
      name: 'Usayd Dev',
      apiBaseUrl: 'http://10.0.2.2:8000/api/v1',
      appIdentifier: 'academy.usayd.learner.dev',
      enableLogging: true,
    );
  });

  group('Localization & Theme Switching Widget Tests', () {
    testWidgets('Arabic locale renders RTL directionality by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        const UsaydApp(
          initialPreferences: UserPreferences(locale: AppLocale.ar),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Directionality widget is RTL
      final directionality = tester.widget<Directionality>(
        find.byType(Directionality).first,
      );
      expect(directionality.textDirection, TextDirection.rtl);

      // Brand name in Arabic
      expect(find.text('أكاديمية أُسَيْد'), findsNWidgets(2));
    });

    testWidgets(
      'Switching language to English updates directionality to LTR dynamically',
      (tester) async {
        await tester.pumpWidget(
          const UsaydApp(
            initialPreferences: UserPreferences(locale: AppLocale.ar),
          ),
        );
        await tester.pumpAndSettle();

        // Tap English segment
        await tester.tap(find.text('الإنجليزية'));
        await tester.pumpAndSettle();

        // Verify Directionality widget is now LTR
        final directionality = tester.widget<Directionality>(
          find.byType(Directionality).first,
        );
        expect(directionality.textDirection, TextDirection.ltr);

        // Verify English localized text appears
        expect(find.text('Usayd Academy'), findsNWidgets(2));
        expect(find.text('Interface Language'), findsOneWidget);
      },
    );

    testWidgets(
      'Toggling theme mode between light and dark updates color scheme',
      (tester) async {
        await tester.pumpWidget(
          const UsaydApp(
            initialPreferences: UserPreferences(
              themeMode: ThemeMode.light,
              interfaceMode: InterfaceMode.pro,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify light colors attached
        BuildContext context = tester.element(find.byType(Scaffold));
        var colors = Theme.of(context).extension<UsaydColorScheme>();
        expect(colors?.bgPage, const Color(0xFFFBF7EE));

        // Tap Dark theme segment
        await tester.tap(find.textContaining('داكن'));
        await tester.pumpAndSettle();

        // Verify dark colors attached
        context = tester.element(find.byType(Scaffold));
        colors = Theme.of(context).extension<UsaydColorScheme>();
        expect(colors?.bgPage, const Color(0xFF0A1B1E));
      },
    );

    testWidgets(
      'Preference independence card displays market and timezone unchanged',
      (tester) async {
        const prefs = UserPreferences(
          locale: AppLocale.ar,
          marketCountry: 'SA',
          currency: 'SAR',
          timezone: 'Asia/Riyadh',
        );

        await tester.pumpWidget(const UsaydApp(initialPreferences: prefs));
        await tester.pumpAndSettle();

        expect(find.text('SA'), findsOneWidget);
        expect(find.text('SAR'), findsOneWidget);
        expect(find.text('Asia/Riyadh'), findsOneWidget);

        // Switch language to English
        await tester.tap(find.text('الإنجليزية'));
        await tester.pumpAndSettle();

        // Market, currency, and timezone remain intact!
        expect(find.text('SA'), findsOneWidget);
        expect(find.text('SAR'), findsOneWidget);
        expect(find.text('Asia/Riyadh'), findsOneWidget);
      },
    );
  });
}
