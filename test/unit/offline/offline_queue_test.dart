import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/offline/encryption/encryption_service.dart';
import 'package:usayd_flutter/core/offline/models/offline_action.dart';
import 'package:usayd_flutter/core/offline/models/sync_status.dart';
import 'package:usayd_flutter/core/offline/offline_queue.dart';
import 'package:usayd_flutter/core/offline/storage/offline_storage.dart';

void main() {
  group('OfflineActionQueue', () {
    late InMemoryOfflineStorage storage;
    late EncryptionService encryption;
    late OfflineActionQueue queue;

    setUp(() {
      storage = InMemoryOfflineStorage();
      encryption = AesGcmEncryptionService(
        staticKey: enc.Key.fromSecureRandom(32),
      );
      queue = OfflineActionQueue(storage: storage, encryption: encryption);
    });

    test('enqueues and retrieves action accurately', () async {
      final action = OfflineAction(
        id: 'act-001',
        endpoint: '/api/v1/recitations',
        method: 'POST',
        payload: {'surah': 1, 'ayah': 1},
        idempotencyKey: 'idem-act-001',
        createdAt: DateTime(2026, 11, 24, 10, 0),
      );

      await queue.enqueue(action);

      final retrieved = await queue.getAction('act-001');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('act-001'));
      expect(retrieved.endpoint, equals('/api/v1/recitations'));
      expect(retrieved.status, equals(SyncStatus.pending));
    });

    test(
      'enforces FIFO ordering on pending actions based on createdAt',
      () async {
        final a2 = OfflineAction(
          id: 'act-002',
          endpoint: '/api/v1/lessons/2',
          method: 'PUT',
          payload: {'step': 2},
          idempotencyKey: 'idem-2',
          createdAt: DateTime(2026, 11, 24, 10, 15),
        );
        final a1 = OfflineAction(
          id: 'act-001',
          endpoint: '/api/v1/lessons/1',
          method: 'PUT',
          payload: {'step': 1},
          idempotencyKey: 'idem-1',
          createdAt: DateTime(2026, 11, 24, 10, 0),
        );
        final a3 = OfflineAction(
          id: 'act-003',
          endpoint: '/api/v1/lessons/3',
          method: 'PUT',
          payload: {'step': 3},
          idempotencyKey: 'idem-3',
          createdAt: DateTime(2026, 11, 24, 10, 30),
        );

        // Enqueue out of order
        await queue.enqueue(a2);
        await queue.enqueue(a3);
        await queue.enqueue(a1);

        final pending = await queue.getPendingActions();
        expect(pending.length, equals(3));
        expect(pending[0].id, equals('act-001'));
        expect(pending[1].id, equals('act-002'));
        expect(pending[2].id, equals('act-003'));
      },
    );

    test('deduplicates actions with identical idempotencyKey', () async {
      final a1 = OfflineAction(
        id: 'act-001',
        endpoint: '/api/v1/attendance',
        method: 'POST',
        payload: {'present': true},
        idempotencyKey: 'idem-dup-check',
        createdAt: DateTime.now(),
      );
      final a2 = OfflineAction(
        id: 'act-002',
        endpoint: '/api/v1/attendance',
        method: 'POST',
        payload: {'present': true},
        idempotencyKey: 'idem-dup-check',
        createdAt: DateTime.now(),
      );

      final r1 = await queue.enqueue(a1);
      final r2 = await queue.enqueue(a2);

      expect(r1.id, equals('act-001'));
      expect(r2.id, equals('act-001'));

      final all = await queue.getAllActions();
      expect(all.length, equals(1));
    });

    test(
      'clears only synced actions leaving pending and conflict intact',
      () async {
        final pending = OfflineAction(
          id: 'p1',
          endpoint: '/api/v1/test',
          method: 'POST',
          payload: {},
          status: SyncStatus.pending,
          idempotencyKey: 'k1',
          createdAt: DateTime.now(),
        );
        final synced = OfflineAction(
          id: 's1',
          endpoint: '/api/v1/test',
          method: 'POST',
          payload: {},
          status: SyncStatus.synced,
          idempotencyKey: 'k2',
          createdAt: DateTime.now(),
        );
        final conflict = OfflineAction(
          id: 'c1',
          endpoint: '/api/v1/test',
          method: 'POST',
          payload: {},
          status: SyncStatus.conflict,
          idempotencyKey: 'k3',
          createdAt: DateTime.now(),
        );

        await queue.enqueue(pending);
        await queue.enqueue(synced);
        await queue.enqueue(conflict);

        expect(await queue.getPendingCount(), equals(1));
        expect(await queue.getConflictCount(), equals(1));

        await queue.clearSynced();

        final remaining = await queue.getAllActions();
        expect(remaining.length, equals(2));
        expect(remaining.any((a) => a.id == 's1'), isFalse);
      },
    );
  });
}
