import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:usayd_flutter/core/network/api_client.dart';
import 'package:usayd_flutter/core/network/models/auth_tokens.dart';
import 'package:usayd_flutter/core/network/token_storage.dart';
import 'package:usayd_flutter/core/offline/encryption/encryption_service.dart';
import 'package:usayd_flutter/core/offline/models/offline_action.dart';
import 'package:usayd_flutter/core/offline/models/sync_status.dart';
import 'package:usayd_flutter/core/offline/offline_queue.dart';
import 'package:usayd_flutter/core/offline/storage/offline_storage.dart';
import 'package:usayd_flutter/core/offline/sync_engine.dart';

void main() {
  group('OfflineSyncEngine', () {
    late InMemoryOfflineStorage storage;
    late EncryptionService encryption;
    late OfflineActionQueue queue;
    late InMemoryAuthTokenStorage tokenStorage;

    setUp(() {
      storage = InMemoryOfflineStorage();
      encryption = AesGcmEncryptionService(
        staticKey: enc.Key.fromSecureRandom(32),
      );
      queue = OfflineActionQueue(storage: storage, encryption: encryption);
      tokenStorage = InMemoryAuthTokenStorage();
    });

    test(
      'synchronizes pending actions in FIFO order and marks synced',
      () async {
        final dispatchedPaths = <String>[];

        final mockClient = MockClient((request) async {
          dispatchedPaths.add(request.url.path);
          expect(request.headers['Idempotency-Key'], isNotNull);

          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': {'id': 'res-100'},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(
          baseUrl: 'https://api.usayd.academy',
          httpClient: mockClient,
          tokenStorage: tokenStorage,
        );

        final engine = OfflineSyncEngine(queue: queue, apiClient: apiClient);

        await queue.enqueue(
          OfflineAction(
            id: 'act-1',
            endpoint: '/api/v1/lessons/step1',
            method: 'POST',
            payload: {'step': 1},
            idempotencyKey: 'idem-1',
            createdAt: DateTime(2026, 11, 24, 9, 0),
          ),
        );
        await queue.enqueue(
          OfflineAction(
            id: 'act-2',
            endpoint: '/api/v1/lessons/step2',
            method: 'POST',
            payload: {'step': 2},
            idempotencyKey: 'idem-2',
            createdAt: DateTime(2026, 11, 24, 9, 5),
          ),
        );

        final result = await engine.syncAll();

        expect(result.syncedCount, equals(2));
        expect(result.conflictCount, equals(0));
        expect(result.isCleanSuccess, isTrue);

        expect(dispatchedPaths, [
          '/api/v1/lessons/step1',
          '/api/v1/lessons/step2',
        ]);

        final a1 = await queue.getAction('act-1');
        expect(a1!.status, equals(SyncStatus.synced));
        expect(a1.syncedAt, isNotNull);

        engine.dispose();
      },
    );

    test(
      'marks action as conflict on 409 without faking server success',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'type': 'https://api.usayd.academy/errors/conflict',
              'title': 'Conflict',
              'status': 409,
              'detail': 'Server recitation version is newer than client draft.',
              'code': 'RESOURCE_CONFLICT',
              'server_version': 5,
            }),
            409,
            headers: {'content-type': 'application/problem+json'},
          );
        });

        final apiClient = ApiClient(
          baseUrl: 'https://api.usayd.academy',
          httpClient: mockClient,
          tokenStorage: tokenStorage,
        );

        final engine = OfflineSyncEngine(queue: queue, apiClient: apiClient);

        await queue.enqueue(
          OfflineAction(
            id: 'act-conflict',
            endpoint: '/api/v1/recitations/42',
            method: 'PUT',
            payload: {'audio_url': 'local_draft.m4a'},
            idempotencyKey: 'idem-conflict',
            createdAt: DateTime.now(),
          ),
        );

        final result = await engine.syncAll();

        expect(result.conflictCount, equals(1));
        expect(result.syncedCount, equals(0));
        expect(result.hasConflicts, isTrue);

        final action = await queue.getAction('act-conflict');
        expect(action!.status, equals(SyncStatus.conflict));
        expect(
          action.errorMessage,
          contains('Server recitation version is newer than client draft.'),
        );
        expect(action.conflictDetails?['server_version'], equals(5));

        engine.dispose();
      },
    );

    test(
      'transient network failure preserves pending status and increments retryCount',
      () async {
        final mockClient = MockClient((request) async {
          throw http.ClientException('Network connection unreachable');
        });

        final apiClient = ApiClient(
          baseUrl: 'https://api.usayd.academy',
          httpClient: mockClient,
          tokenStorage: tokenStorage,
        );

        final engine = OfflineSyncEngine(queue: queue, apiClient: apiClient);

        await queue.enqueue(
          OfflineAction(
            id: 'act-net',
            endpoint: '/api/v1/notes',
            method: 'POST',
            payload: {'content': 'My offline note'},
            idempotencyKey: 'idem-net',
            createdAt: DateTime.now(),
          ),
        );

        final result = await engine.syncAll();

        expect(result.retryCount, equals(1));
        expect(result.syncedCount, equals(0));

        final action = await queue.getAction('act-net');
        expect(action!.status, equals(SyncStatus.pending));
        expect(action.retryCount, equals(1));
        expect(action.errorMessage, contains('Network connection unreachable'));

        engine.dispose();
      },
    );

    test('does not replay a successful mutation with invalid JSON', () async {
      var dispatches = 0;
      final apiClient = ApiClient(
        baseUrl: 'https://api.usayd.academy',
        tokenStorage: tokenStorage,
        httpClient: MockClient((request) async {
          dispatches++;
          return http.Response('invalid JSON', 200);
        }),
      );
      final engine = OfflineSyncEngine(queue: queue, apiClient: apiClient);
      addTearDown(engine.dispose);
      await queue.enqueue(
        OfflineAction(
          id: 'malformed-success',
          endpoint: '/api/v1/notes',
          method: 'POST',
          payload: {},
          idempotencyKey: 'malformed-success-key',
          createdAt: DateTime.now(),
        ),
      );

      final result = await engine.syncAll();
      expect(result.conflictCount, 1);
      expect(result.retryCount, 0);
      final action = await queue.getAction('malformed-success');
      expect(action?.status, SyncStatus.conflict);
      await engine.syncAll();
      expect(dispatches, 1);
    });

    test('invalid refresh response leaves rejected mutation pending', () async {
      await tokenStorage.saveTokens(
        const AuthTokens(
          accessToken: 'old-access',
          expiresIn: 3600,
          refreshToken: 'old-refresh',
          tokenType: 'Bearer',
        ),
      );
      var mutationCalls = 0;
      var refreshCalls = 0;
      final apiClient = ApiClient(
        baseUrl: 'https://api.usayd.academy',
        tokenStorage: tokenStorage,
        httpClient: MockClient((request) async {
          if (request.url.path == '/api/v1/auth/refresh') {
            refreshCalls++;
            return http.Response('invalid JSON', 200);
          }
          mutationCalls++;
          return http.Response('{"status":401}', 401);
        }),
      );
      final engine = OfflineSyncEngine(queue: queue, apiClient: apiClient);
      addTearDown(engine.dispose);
      await queue.enqueue(
        OfflineAction(
          id: 'malformed-refresh',
          endpoint: '/api/v1/notes',
          method: 'POST',
          payload: {},
          idempotencyKey: 'malformed-refresh-key',
          createdAt: DateTime.now(),
        ),
      );

      final result = await engine.syncAll();
      expect(result.conflictCount, 0);
      expect(result.retryCount, 1);
      final action = await queue.getAction('malformed-refresh');
      expect(action?.status, SyncStatus.pending);
      expect(mutationCalls, 1);
      expect(refreshCalls, 1);
    });

    test('422 validation failure marks action as failed', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'type': 'https://api.usayd.academy/errors/validation',
            'title': 'Unprocessable Entity',
            'status': 422,
            'detail': 'The name field is required.',
            'code': 'VALIDATION_ERROR',
          }),
          422,
          headers: {'content-type': 'application/problem+json'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.usayd.academy',
        httpClient: mockClient,
        tokenStorage: tokenStorage,
      );

      final engine = OfflineSyncEngine(queue: queue, apiClient: apiClient);

      await queue.enqueue(
        OfflineAction(
          id: 'act-val',
          endpoint: '/api/v1/profile',
          method: 'PUT',
          payload: {'name': ''},
          idempotencyKey: 'idem-val',
          createdAt: DateTime.now(),
        ),
      );

      final result = await engine.syncAll();

      expect(result.failedCount, equals(1));
      final action = await queue.getAction('act-val');
      expect(action!.status, equals(SyncStatus.failed));

      engine.dispose();
    });

    test('HTTP 429 Rate Limited handles retry-after gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'type': 'https://api.usayd.academy/errors/rate-limit',
            'title': 'Too Many Requests',
            'status': 429,
            'detail': 'Rate limit exceeded. Try again in 60 seconds.',
            'retry_after': 60,
          }),
          429,
          headers: {'content-type': 'application/problem+json'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.usayd.academy',
        httpClient: mockClient,
        tokenStorage: tokenStorage,
      );

      final engine = OfflineSyncEngine(queue: queue, apiClient: apiClient);

      await queue.enqueue(
        OfflineAction(
          id: 'act-rate',
          endpoint: '/api/v1/recitations',
          method: 'POST',
          payload: {'surah': 1},
          idempotencyKey: 'idem-rate',
          createdAt: DateTime.now(),
        ),
      );

      final result = await engine.syncAll();

      expect(result.retryCount, equals(1));
      expect(result.failedCount, equals(0));

      final action = await queue.getAction('act-rate');
      expect(action!.status, equals(SyncStatus.pending));
      expect(action.retryCount, equals(1));
      expect(action.errorMessage, contains('Rate limited'));

      engine.dispose();
    });

    test('skips actions belonging to different logged-in user', () async {
      final dispatchedPaths = <String>[];
      final mockClient = MockClient((request) async {
        dispatchedPaths.add(request.url.path);
        return http.Response(
          '{"status":"ok"}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.usayd.academy',
        httpClient: mockClient,
        tokenStorage: tokenStorage,
      );

      final engine = OfflineSyncEngine(queue: queue, apiClient: apiClient);

      await queue.enqueue(
        OfflineAction(
          id: 'act-usr1',
          userId: 'user_111',
          endpoint: '/api/v1/user1/data',
          method: 'POST',
          payload: {},
          idempotencyKey: 'idem-u1',
          createdAt: DateTime.now(),
        ),
      );
      await queue.enqueue(
        OfflineAction(
          id: 'act-usr2',
          userId: 'user_222',
          endpoint: '/api/v1/user2/data',
          method: 'POST',
          payload: {},
          idempotencyKey: 'idem-u2',
          createdAt: DateTime.now(),
        ),
      );

      // Sync strictly for user_111
      final result = await engine.syncAll(currentUserId: 'user_111');

      expect(result.syncedCount, equals(1));
      expect(dispatchedPaths, equals(['/api/v1/user1/data']));

      final a1 = await queue.getAction('act-usr1', userId: 'user_111');
      expect(a1!.status, equals(SyncStatus.synced));

      final a2 = await queue.getAction('act-usr2', userId: 'user_222');
      expect(a2!.status, equals(SyncStatus.pending));

      engine.dispose();
    });
  });
}
