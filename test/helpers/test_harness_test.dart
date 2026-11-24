import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/config/flavor_config.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';
import 'package:usayd_flutter/core/localization/app_locale.dart';
import 'package:usayd_flutter/core/localization/usayd_localizations.dart';
import 'package:usayd_flutter/core/network/models/auth_tokens.dart';
import 'package:usayd_flutter/core/theme/usayd_colors.dart';
import 'package:usayd_flutter/core/theme/usayd_mode_theme.dart';
import '../helpers/test_harness.dart';

void main() {
  setUp(() {
    TestHarness.initFlavor();
  });

  group('TestHarness Infrastructure & Mocks', () {
    test('FlavorConfig initializes with test defaults', () {
      expect(FlavorConfig.isDev, isTrue);
      expect(FlavorConfig.instance.name, isNotEmpty);
      expect(FlavorConfig.instance.apiBaseUrl, isNotEmpty);
    });

    test('createMockTokenStorage handles save, read, and clear', () async {
      final storage = TestHarness.createMockTokenStorage();
      expect(await storage.hasAccessToken(), isFalse);

      const tokens = AuthTokens(
        accessToken: 'access-123',
        refreshToken: 'refresh-456',
        expiresIn: 3600,
        tokenType: 'Bearer',
      );

      await storage.saveTokens(tokens);
      expect(await storage.hasAccessToken(), isTrue);

      final retrieved = await storage.getTokens();
      expect(retrieved?.accessToken, 'access-123');

      await storage.clearTokens();
      expect(await storage.hasAccessToken(), isFalse);
    });

    test('createMockOfflineStorage handles key-value lifecycle', () async {
      final storage = TestHarness.createMockOfflineStorage();
      expect(await storage.read('key1'), isNull);

      await storage.write('key1', 'value1');
      expect(await storage.read('key1'), 'value1');

      final all = await storage.readAll();
      expect(all['key1'], 'value1');

      await storage.delete('key1');
      expect(await storage.read('key1'), isNull);

      await storage.write('k1', 'v1');
      await storage.write('k2', 'v2');
      await storage.clear();
      expect(await storage.readAll(), isEmpty);
    });

    test('createMockApiClient performs login and profile fetch', () async {
      final client = TestHarness.createMockApiClient();
      final tokens = await client.login(
        email: 'test@usayd.academy',
        password: 'password123',
      );
      expect(tokens.accessToken, isNotEmpty);

      final profile = await client.getProfile();
      expect(profile.name, isNotEmpty);
      expect(profile.email, isNotEmpty);
    });
  });

  group('TestHarness pumpUsaydWidget Capabilities', () {
    testWidgets(
      'pumps widget with RTL directionality and Arabic localizations',
      (tester) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          Builder(
            builder: (context) {
              final l10n = UsaydLocalizations.of(context);
              final direction = Directionality.of(context);
              return Column(
                children: [
                  Text('Direction: ${direction.name}'),
                  Text('Brand: ${l10n.brandName}'),
                ],
              );
            },
          ),
          locale: AppLocale.ar,
        );

        expect(find.text('Direction: rtl'), findsOneWidget);
        expect(find.text('Brand: أكاديمية أُسَيْد'), findsOneWidget);
      },
    );

    testWidgets(
      'pumps widget with LTR directionality and English localizations',
      (tester) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          Builder(
            builder: (context) {
              final l10n = UsaydLocalizations.of(context);
              final direction = Directionality.of(context);
              return Column(
                children: [
                  Text('Direction: ${direction.name}'),
                  Text('Brand: ${l10n.brandName}'),
                ],
              );
            },
          ),
          locale: AppLocale.en,
        );

        expect(find.text('Direction: ltr'), findsOneWidget);
        expect(find.text('Brand: Usayd Academy'), findsOneWidget);
      },
    );

    testWidgets('pumps widget with Dark Theme correctly attached', (
      tester,
    ) async {
      await TestHarness.pumpUsaydWidget(
        tester,
        Builder(
          builder: (context) {
            final colors = Theme.of(context).extension<UsaydColorScheme>();
            return Text('Night: ${colors?.bgPage.value}');
          },
        ),
        themeMode: ThemeMode.dark,
      );

      expect(find.textContaining('Night:'), findsOneWidget);
    });

    testWidgets('pumps widget with Kids Mode tokens attached', (tester) async {
      await TestHarness.pumpUsaydWidget(
        tester,
        Builder(
          builder: (context) {
            final modeTheme = Theme.of(context).extension<UsaydModeTheme>();
            return Column(
              children: [
                Text('Mode: ${modeTheme?.mode.name}'),
                Text('ButtonHeight: ${modeTheme?.buttonHeight}'),
                Text('Radius: ${modeTheme?.cardRadius}'),
              ],
            );
          },
        ),
        mode: InterfaceMode.kids,
      );

      expect(find.text('Mode: kids'), findsOneWidget);
      expect(find.text('ButtonHeight: 56.0'), findsOneWidget);
      expect(find.text('Radius: 24.0'), findsOneWidget);
    });

    testWidgets('pumps widget with Simple Mode tokens attached', (
      tester,
    ) async {
      await TestHarness.pumpUsaydWidget(
        tester,
        Builder(
          builder: (context) {
            final modeTheme = Theme.of(context).extension<UsaydModeTheme>();
            return Column(
              children: [
                Text('Mode: ${modeTheme?.mode.name}'),
                Text('ButtonHeight: ${modeTheme?.buttonHeight}'),
                Text('BorderWidth: ${modeTheme?.cardBorderWidth}'),
              ],
            );
          },
        ),
        mode: InterfaceMode.simple,
      );

      expect(find.text('Mode: simple'), findsOneWidget);
      expect(find.text('ButtonHeight: 60.0'), findsOneWidget);
      expect(find.text('BorderWidth: 1.5'), findsOneWidget);
    });

    testWidgets('sets responsive breakpoints properly', (tester) async {
      await TestHarness.pumpUsaydWidget(
        tester,
        const Center(child: Text('Responsive Test')),
        breakpoint: ScreenBreakpoint.compactPhone,
      );

      expect(tester.view.physicalSize.width, 320 * 2.0);
      expect(tester.view.physicalSize.height, 640 * 2.0);
      expect(tester.view.devicePixelRatio, 2.0);
    });
  });
}
