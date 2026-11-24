import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/config/flavor_config.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';
import 'package:usayd_flutter/core/config/user_preferences.dart';
import 'package:usayd_flutter/core/localization/app_locale.dart';
import 'package:usayd_flutter/core/localization/usayd_localizations.dart';
import 'package:usayd_flutter/core/network/api_client.dart';
import 'package:usayd_flutter/core/network/mock/mock_api_client.dart';
import 'package:usayd_flutter/core/network/token_storage.dart';
import 'package:usayd_flutter/core/offline/storage/offline_storage.dart';
import 'package:usayd_flutter/core/theme/usayd_theme.dart';

/// Screen breakpoint specifications for responsive verification
/// per Usayd visual guidelines and target device matrix.
enum ScreenBreakpoint {
  /// 320x640 @2.0x — Compact Phone (iPhone SE 1st gen, small Android)
  compactPhone(Size(320, 640), 2.0),

  /// 390x844 @3.0x — Standard Phone (iPhone 12/13/14/15, modern Android)
  standardPhone(Size(390, 844), 3.0),

  /// 768x1024 @2.0x — Tablet (iPad Mini, 7-8" Android tablets)
  tablet(Size(768, 1024), 2.0);

  final Size logicalSize;
  final double pixelRatio;

  const ScreenBreakpoint(this.logicalSize, this.pixelRatio);

  Size get physicalSize =>
      Size(logicalSize.width * pixelRatio, logicalSize.height * pixelRatio);
}

/// Unified Test Harness for Usayd Academy Flutter application.
/// Provides mock infrastructure, responsive viewport helpers,
/// and standardized widget pumping with full localization and theme context.
class TestHarness {
  static bool _flavorInitialized = false;

  /// Ensures FlavorConfig is initialized cleanly once for test suites.
  static void initFlavor({AppFlavor flavor = AppFlavor.dev}) {
    if (_flavorInitialized) return;
    try {
      FlavorConfig.init(
        flavor: flavor,
        name: 'Usayd Test',
        apiBaseUrl: 'http://127.0.0.1:8000/api/v1',
        appIdentifier: 'academy.usayd.learner.test',
        enableLogging: false,
      );
      _flavorInitialized = true;
    } catch (_) {
      // FlavorConfig already initialized in a previous test
      _flavorInitialized = true;
    }
  }

  /// Creates a mock TokenStorage backed by memory.
  static InMemoryAuthTokenStorage createMockTokenStorage() {
    return InMemoryAuthTokenStorage();
  }

  /// Creates a mock OfflineStorage backed by memory.
  static InMemoryOfflineStorage createMockOfflineStorage() {
    return InMemoryOfflineStorage();
  }

  /// Creates a MockApiClient with in-memory storage.
  static MockApiClient createMockApiClient({
    AuthTokenStorage? tokenStorage,
    LocaleProvider? localeProvider,
  }) {
    return MockApiClient(
      tokenStorage: tokenStorage ?? createMockTokenStorage(),
      localeProvider: localeProvider ?? (() => 'ar'),
    );
  }

  /// Applies a specific responsive breakpoint to the WidgetTester view.
  static void setBreakpoint(WidgetTester tester, ScreenBreakpoint breakpoint) {
    tester.view.physicalSize = breakpoint.physicalSize;
    tester.view.devicePixelRatio = breakpoint.pixelRatio;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  /// Applies custom dimensions to the WidgetTester view.
  static void setCustomSize(
    WidgetTester tester, {
    required Size logicalSize,
    double pixelRatio = 1.0,
  }) {
    tester.view.physicalSize = Size(
      logicalSize.width * pixelRatio,
      logicalSize.height * pixelRatio,
    );
    tester.view.devicePixelRatio = pixelRatio;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  /// Pumps a widget under test wrapped in the full Usayd environment:
  /// - MaterialApp with authentic UsaydTheme.light / dark
  /// - UsaydLocalizations and standard Flutter delegates
  /// - Correct Directionality (RTL for Arabic, LTR for English)
  /// - Optional responsive breakpoint viewport setup
  static Future<void> pumpUsaydWidget(
    WidgetTester tester,
    Widget child, {
    InterfaceMode mode = InterfaceMode.pro,
    ThemeMode themeMode = ThemeMode.light,
    AppLocale locale = AppLocale.ar,
    ScreenBreakpoint? breakpoint,
    Size? customLogicalSize,
    double? customPixelRatio,
    UserPreferences? preferences,
    bool settle = true,
  }) async {
    initFlavor();

    if (breakpoint != null) {
      setBreakpoint(tester, breakpoint);
    } else if (customLogicalSize != null) {
      setCustomSize(
        tester,
        logicalSize: customLogicalSize,
        pixelRatio: customPixelRatio ?? 1.0,
      );
    }

    final testApp = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: UsaydTheme.light(mode),
      darkTheme: UsaydTheme.dark(mode),
      themeMode: themeMode,
      locale: locale.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        UsaydLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Directionality(
        textDirection: locale.isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(body: child),
      ),
    );

    await tester.pumpWidget(testApp);
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }
}
