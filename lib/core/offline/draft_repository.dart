import 'dart:convert';
import 'encryption/encryption_service.dart';
import 'models/local_draft.dart';
import 'models/sync_status.dart';
import 'storage/offline_storage.dart';

class DraftRepository {
  static const String _draftPrefix = 'local_draft_';

  final OfflineStorage _storage;
  final EncryptionService _encryption;

  DraftRepository({
    required OfflineStorage storage,
    required EncryptionService encryption,
  }) : _storage = storage,
       _encryption = encryption;

  String _formatKey(String userId, String id) => '$_draftPrefix${userId}_$id';

  Future<void> saveDraft(LocalDraft draft) async {
    final jsonString = jsonEncode(draft.toJson());
    final encrypted = await _encryption.encrypt(jsonString);
    await _storage.write(_formatKey(draft.userId, draft.id), encrypted);
  }

  Future<LocalDraft?> getDraft(String id, {String? userId}) async {
    if (userId != null) {
      final encrypted = await _storage.read(_formatKey(userId, id));
      if (encrypted != null) {
        final decrypted = await _encryption.decrypt(encrypted);
        final json = jsonDecode(decrypted) as Map<String, dynamic>;
        return LocalDraft.fromJson(json);
      }
    }

    final allEntries = await _storage.readAll();
    for (final entry in allEntries.entries) {
      if (entry.key.startsWith(_draftPrefix) && entry.key.endsWith('_$id')) {
        try {
          final decrypted = await _encryption.decrypt(entry.value);
          final json = jsonDecode(decrypted) as Map<String, dynamic>;
          final draft = LocalDraft.fromJson(json);
          if (draft.id == id) {
            return draft;
          }
        } catch (_) {}
      }
    }
    return null;
  }

  Future<List<LocalDraft>> listDrafts({
    String? userId,
    String? draftType,
  }) async {
    final allEntries = await _storage.readAll();
    final drafts = <LocalDraft>[];

    for (final entry in allEntries.entries) {
      if (entry.key.startsWith(_draftPrefix)) {
        try {
          final decrypted = await _encryption.decrypt(entry.value);
          final json = jsonDecode(decrypted) as Map<String, dynamic>;
          final draft = LocalDraft.fromJson(json);
          if (userId != null && draft.userId != userId) {
            continue;
          }
          if (draftType == null || draft.draftType == draftType) {
            drafts.add(draft);
          }
        } catch (_) {
          // Skip corrupted or unreadable draft
        }
      }
    }

    drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return drafts;
  }

  Future<void> deleteDraft(String id, {String? userId}) async {
    if (userId != null) {
      await _storage.delete(_formatKey(userId, id));
      return;
    }

    final allEntries = await _storage.readAll();
    for (final entry in allEntries.entries) {
      if (entry.key.startsWith(_draftPrefix) && entry.key.endsWith('_$id')) {
        await _storage.delete(entry.key);
      }
    }
  }

  Future<void> markConflict(
    String id,
    Map<String, dynamic> serverData, {
    String? userId,
  }) async {
    final draft = await getDraft(id, userId: userId);
    if (draft != null) {
      final updated = draft.copyWith(
        status: SyncStatus.conflict,
        conflictData: serverData,
        updatedAt: DateTime.now(),
      );
      await saveDraft(updated);
    }
  }
}
