import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/config/flavor_config.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';
import 'package:usayd_flutter/core/config/user_preferences.dart';
import 'package:usayd_flutter/core/localization/app_locale.dart';
import '../helpers/authenticated_app_fixture.dart';

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

  group('AdaptiveShell Responsive Navigation Widget Tests', () {
    testWidgets('Pro mode renders 5 navigation destinations in NavigationBar', (
      tester,
    ) async {
      await tester.pumpWidget(
        authenticatedAppFixture(
          initialPreferences: const UserPreferences(
            interfaceMode: InterfaceMode.pro,
            locale: AppLocale.ar,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.destinations.length, 5);
      expect(find.text('الرئيسية'), findsWidgets);
      expect(find.text('الدروس'), findsOneWidget);
      expect(find.text('التلاوة'), findsOneWidget);
      expect(find.text('تقدمي'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);
    });

    testWidgets(
      'Kids mode renders 4 navigation destinations in NavigationBar',
      (tester) async {
        await tester.pumpWidget(
          authenticatedAppFixture(
            initialPreferences: const UserPreferences(
              interfaceMode: InterfaceMode.kids,
              locale: AppLocale.ar,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.destinations.length, 4);
        expect(find.text('مهمتي'), findsOneWidget);
        expect(find.text('طريقي'), findsOneWidget);
        expect(find.text('نجومي'), findsOneWidget);
        expect(find.text('أنا'), findsOneWidget);
      },
    );

    testWidgets(
      'Simple mode renders 3 navigation destinations in NavigationBar',
      (tester) async {
        await tester.pumpWidget(
          authenticatedAppFixture(
            initialPreferences: const UserPreferences(
              interfaceMode: InterfaceMode.simple,
              locale: AppLocale.ar,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.destinations.length, 3);
        expect(find.text('ورد اليوم'), findsOneWidget);
        expect(find.text('الدروس'), findsOneWidget);
        expect(find.text('المساعدة'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping navigation destination switches visible screen content',
      (tester) async {
        await tester.pumpWidget(
          authenticatedAppFixture(
            initialPreferences: const UserPreferences(
              interfaceMode: InterfaceMode.pro,
              locale: AppLocale.ar,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap on Lessons tab
        await tester.tap(find.text('الدروس'));
        await tester.pumpAndSettle();

        // Screen content updates to Lessons
        expect(find.textContaining('LESSONS'), findsOneWidget);

        // Tap on Recite tab
        await tester.tap(find.text('التلاوة'));
        await tester.pumpAndSettle();

        // Screen content updates to Recite
        expect(find.textContaining('RECITE'), findsOneWidget);
      },
    );

    testWidgets(
      'Switching mode from Pro to Simple safely clamps active tab index',
      (tester) async {
        await tester.pumpWidget(
          authenticatedAppFixture(
            initialPreferences: const UserPreferences(
              interfaceMode: InterfaceMode.pro,
              locale: AppLocale.ar,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap tab 4 (Profile)
        await tester.tap(find.text('حسابي'));
        await tester.pumpAndSettle();
        expect(find.textContaining('PROFILE'), findsOneWidget);

        // Now tap Home tab, switch to Simple mode
        await tester.tap(find.text('الرئيسية'));
        await tester.pumpAndSettle();

        // Tap on Simple mode segment in HomeScreen
        final simpleSegment = find.text(InterfaceMode.simple.displayNameArabic);
        await tester.ensureVisible(simpleSegment);
        await tester.tap(simpleSegment);
        await tester.pumpAndSettle();

        // Ensure NavigationBar clamped to 3 items without throwing index errors
        final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.destinations.length, 3);
      },
    );

    testWidgets(
      'AdaptiveShell configures resizeToAvoidBottomInset for keyboard safety',
      (tester) async {
        await tester.pumpWidget(
          authenticatedAppFixture(
            initialPreferences: const UserPreferences(
              interfaceMode: InterfaceMode.pro,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(scaffold.resizeToAvoidBottomInset, isTrue);
      },
    );
  });
}
