import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/app.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';
import 'package:usayd_flutter/core/localization/app_locale.dart';
import 'package:usayd_flutter/core/widgets/screen_state_view.dart';
import '../helpers/test_harness.dart';

void main() {
  setUp(() {
    TestHarness.initFlavor();
  });

  group('Golden Smoke & Structural Hierarchy Tests', () {
    testWidgets('Full UsaydApp renders canopy, brand mark, and shell', (
      tester,
    ) async {
      await tester.pumpWidget(const UsaydApp(initialMode: InterfaceMode.pro));
      await tester.pumpAndSettle();

      // Brand mark and sacred name
      expect(find.text('أكاديمية أُسَيْد'), findsWidgets);
      expect(find.text('«اقرأ بصوتٍ تدنو له الملائكة»'), findsOneWidget);

      // Verify no exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'ScreenStateView preserves sacred name intact without alteration',
      (tester) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          const ScreenStateView.empty(
            title: 'أكاديمية أُسَيْد المباركة',
            message: '«اقرأ بصوتٍ تدنو له الملائكة»',
          ),
          locale: AppLocale.ar,
        );

        // Exact diacritics check
        expect(find.text('أكاديمية أُسَيْد المباركة'), findsOneWidget);
        expect(find.text('«اقرأ بصوتٍ تدنو له الملائكة»'), findsOneWidget);
      },
    );

    testWidgets(
      'Hierarchy verification for ScreenStateView with child content',
      (tester) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenStateView.offlineBanner(
            overrideMode: InterfaceMode.pro,
            pendingActionsCount: 5,
            child: const Center(
              key: ValueKey('main_content'),
              child: Text('Main Content Under Offline Banner'),
            ),
          ),
        );

        expect(find.byKey(const ValueKey('main_content')), findsOneWidget);
        expect(find.text('Main Content Under Offline Banner'), findsOneWidget);
        expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      },
    );
  });
}
