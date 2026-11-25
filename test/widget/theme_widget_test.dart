import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/config/flavor_config.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';
import 'package:usayd_flutter/core/theme/usayd_colors.dart';
import 'package:usayd_flutter/core/theme/usayd_mode_theme.dart';
import 'package:usayd_flutter/core/theme/usayd_theme.dart';

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

  group('UsaydTheme Widget & Assembly Tests', () {
    testWidgets(
      'UsaydTheme.light attaches UsaydColorScheme and UsaydModeTheme extensions',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: UsaydTheme.light(InterfaceMode.kids),
            home: Builder(
              builder: (context) {
                final colors = Theme.of(context).extension<UsaydColorScheme>();
                final mode = Theme.of(context).extension<UsaydModeTheme>();

                return Scaffold(
                  body: Column(
                    children: [
                      Text('Theme Page: ${colors?.bgPage.value}'),
                      Text('Mode: ${mode?.mode.name}'),
                      Text('Button Height: ${mode?.buttonHeight}'),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        expect(find.textContaining('Theme Page:'), findsOneWidget);
        expect(find.text('Mode: kids'), findsOneWidget);
        expect(find.text('Button Height: 56.0'), findsOneWidget);
      },
    );

    testWidgets('UsaydTheme.dark attaches dark palette properly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: UsaydTheme.dark(InterfaceMode.pro),
          home: Builder(
            builder: (context) {
              final colors = Theme.of(context).extension<UsaydColorScheme>();
              final mode = Theme.of(context).extension<UsaydModeTheme>();

              return Scaffold(
                body: Column(
                  children: [
                    Text('Dark Page: ${colors?.bgPage.value}'),
                    Text('Mode: ${mode?.mode.name}'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.textContaining('Dark Page:'), findsOneWidget);
      expect(find.text('Mode: pro'), findsOneWidget);
    });

    testWidgets(
      'UsaydApp renders with complete theme extensions and mode toggle',
      (tester) async {
        await tester.pumpWidget(authenticatedAppFixture(initialMode: InterfaceMode.pro));
        await tester.pumpAndSettle();

        // Check brand name and sacred tagline
        expect(
          find.text('أكاديمية أُسَيْد'),
          findsNWidgets(2),
        ); // AppBar + Canopy
        expect(find.text('«اقرأ بصوتٍ تدنو له الملائكة»'), findsOneWidget);

        // Verify theme extension was loaded
        final BuildContext context = tester.element(
          find.byType(Scaffold).first,
        );
        final colors = Theme.of(context).extension<UsaydColorScheme>();
        expect(colors, isNotNull);
        expect(colors?.bgBrand, const Color(0xFF0F2529));

        // Toggle to Simple mode
        final simpleBtn = find.text('النمط الميسر (كبار السن)');
        await tester.ensureVisible(simpleBtn);
        await tester.tap(simpleBtn);
        await tester.pumpAndSettle();

        expect(
          find.textContaining('النمط النشط: النمط الميسر (كبار السن)'),
          findsOneWidget,
        );
        expect(
          find.textContaining('الفئة المستهدفة: كبار السن'),
          findsOneWidget,
        );
      },
    );
  });
}
