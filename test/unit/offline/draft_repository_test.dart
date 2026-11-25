import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/offline/draft_repository.dart';
import 'package:usayd_flutter/core/offline/encryption/encryption_service.dart';
import 'package:usayd_flutter/core/offline/models/local_draft.dart';
import 'package:usayd_flutter/core/offline/models/sync_status.dart';
import 'package:usayd_flutter/core/offline/storage/offline_storage.dart';

void main() {
  group('DraftRepository', () {
    late InMemoryOfflineStorage storage;
    late EncryptionService encryption;
    late DraftRepository repository;

    setUp(() {
      storage = InMemoryOfflineStorage();
      encryption = AesGcmEncryptionService(
        staticKey: enc.Key.fromSecureRandom(32),
      );
      repository = DraftRepository(storage: storage, encryption: encryption);
    });

    test('saves and retrieves local draft with encryption', () async {
      final draft = LocalDraft(
        id: 'draft-001',
        draftType: 'recitation_submission',
        data: {
          'surah_number': 18,
          'ayah_start': 1,
          'ayah_end': 10,
          'audio_path': '/local/recordings/cave.m4a',
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveDraft(draft);

      final retrieved = await repository.getDraft('draft-001', userId: 'default_user');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('draft-001'));
      expect(retrieved.draftType, equals('recitation_submission'));
      expect(retrieved.data['surah_number'], equals(18));
      expect(retrieved.status, equals(SyncStatus.pending));
    });

    test(
      'lists drafts filtered by draftType ordered by updatedAt descending',
      () async {
        final d1 = LocalDraft(
          id: 'd1',
          draftType: 'quiz_response',
          data: {'q1': 'A'},
          createdAt: DateTime(2026, 11, 24, 8, 0),
          updatedAt: DateTime(2026, 11, 24, 8, 10),
        );
        final d2 = LocalDraft(
          id: 'd2',
          draftType: 'recitation_submission',
          data: {'surah': 1},
          createdAt: DateTime(2026, 11, 24, 9, 0),
          updatedAt: DateTime(2026, 11, 24, 9, 30),
        );
        final d3 = LocalDraft(
          id: 'd3',
          draftType: 'quiz_response',
          data: {'q2': 'B'},
          createdAt: DateTime(2026, 11, 24, 10, 0),
          updatedAt: DateTime(2026, 11, 24, 10, 15),
        );

        await repository.saveDraft(d1);
        await repository.saveDraft(d2);
        await repository.saveDraft(d3);

        final quizzes = await repository.listDrafts(userId: 'default_user', draftType: 'quiz_response');
        expect(quizzes.length, equals(2));
        expect(quizzes[0].id, equals('d3')); // Newest first
        expect(quizzes[1].id, equals('d1'));

        final all = await repository.listDrafts(userId: 'default_user');
        expect(all.length, equals(3));
      },
    );

    test('marks conflict with server divergence payload', () async {
      final draft = LocalDraft(
        id: 'd-conf',
        draftType: 'lesson_notes',
        data: {'text': 'Student offline notes'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveDraft(draft);

      await repository.markConflict('d-conf', {
        'server_text': 'Teacher modified notes',
      }, userId: 'default_user');

      final updated = await repository.getDraft('d-conf', userId: 'default_user');
      expect(updated!.status, equals(SyncStatus.conflict));
      expect(
        updated.conflictData?['server_text'],
        equals('Teacher modified notes'),
      );
    });

    test('scoped lookup and mutation never fall back to another user', () async {
      final draft = LocalDraft(
        id: 'shared-id',
        userId: 'account-a',
        draftType: 'notes',
        data: {'text': 'private'},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.saveDraft(draft);
      expect(
        await repository.getDraft('shared-id', userId: 'account-b'),
        isNull,
      );
      expect(await repository.listDrafts(userId: 'account-b'), isEmpty);
      await repository.markConflict('shared-id', {}, userId: 'account-b');
      await repository.deleteDraft('shared-id', userId: 'account-b');
      final original = await repository.getDraft(
        'shared-id',
        userId: 'account-a',
      );
      expect(original?.status, SyncStatus.pending);
      expect(original?.data['text'], 'private');
    });

    test('deletes draft successfully', () async {
      final draft = LocalDraft(
        id: 'd-del',
        draftType: 'temp',
        data: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveDraft(draft);
      expect(await repository.getDraft('d-del', userId: 'default_user'), isNotNull);

      await repository.deleteDraft('d-del', userId: 'default_user');
      expect(await repository.getDraft('d-del', userId: 'default_user'), isNull);
    });
  });
}
