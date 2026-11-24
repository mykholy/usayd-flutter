import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/network/api_client.dart';
import 'package:usayd_flutter/core/network/token_storage.dart';
import 'package:usayd_flutter/core/offline/encryption/encryption_service.dart';
import 'package:usayd_flutter/core/offline/offline_queue.dart';
import 'package:usayd_flutter/core/offline/storage/offline_storage.dart';
import 'package:usayd_flutter/core/offline/sync_engine.dart';
import 'package:usayd_flutter/core/theme/usayd_theme.dart';
import 'package:usayd_flutter/features/offline/presentation/offline_sync_indicator.dart';

void main() {
  group('OfflineSyncIndicator Widget', () {
    late OfflineSyncEngine engine;

    setUp(() {
      final storage = InMemoryOfflineStorage();
      final encryption = AesGcmEncryptionService();
      final queue = OfflineActionQueue(
        storage: storage,
        encryption: encryption,
      );
      final apiClient = ApiClient(
        baseUrl: 'https://api.usayd.academy',
        tokenStorage: InMemoryAuthTokenStorage(),
      );
      engine = OfflineSyncEngine(queue: queue, apiClient: apiClient);
    });

    Widget createTestableWidget({
      int pendingCount = 0,
      int conflictCount = 0,
      VoidCallback? onSyncPressed,
      Locale locale = const Locale('ar'),
    }) {
      return MaterialApp(
        theme: UsaydTheme.light(),
        locale: locale,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar'), Locale('en')],
        home: Scaffold(
          body: OfflineSyncIndicator(
            syncEngine: engine,
            pendingCount: pendingCount,
            conflictCount: conflictCount,
            onSyncPressed: onSyncPressed,
          ),
        ),
      );
    }

    testWidgets('renders nothing when pending and conflict counts are zero', (
      tester,
    ) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('renders pending indicator with count and sync button', (
      tester,
    ) async {
      bool syncTapped = false;
      await tester.pumpWidget(
        createTestableWidget(
          pendingCount: 3,
          onSyncPressed: () => syncTapped = true,
        ),
      );

      expect(find.text('3 في الانتظار'), findsOneWidget);
      expect(find.text('مزامنة الآن'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_queue_rounded), findsOneWidget);

      await tester.tap(find.text('مزامنة الآن'));
      expect(syncTapped, isTrue);
    });

    testWidgets('renders English labels when English locale is used', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestableWidget(pendingCount: 2, locale: const Locale('en')),
      );

      expect(find.text('2 pending sync'), findsOneWidget);
      expect(find.text('Sync now'), findsOneWidget);
    });

    testWidgets('renders conflict warning banner when conflictCount > 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestableWidget(pendingCount: 1, conflictCount: 2),
      );

      expect(
        find.text('يوجد 2 تعارض في المزامنة يتطلب المراجعة'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });
}
