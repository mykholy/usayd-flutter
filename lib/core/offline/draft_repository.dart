import 'dart:convert';
import 'encryption/encryption_service.dart';
import 'models/local_draft.dart';
import 'models/sync_status.dart';
import 'storage/offline_storage.dart';

class DraftRepository {
  static const String _draftPrefix = 'draft_';

  final OfflineStorage _storage;
  final EncryptionService _encryption;

  DraftRepository({
    required OfflineStorage storage,
    required EncryptionService encryption,
  }) : _storage = storage,
       _encryption = encryption;

  String _formatKey(String id) => '$_draftPrefix$id';

  Future<void> saveDraft(LocalDraft draft) async {
    final jsonString = jsonEncode(draft.toJson());
    final encrypted = await _encryption.encrypt(jsonString);
    await _storage.write(_formatKey(draft.id), encrypted);
  }

  Future<LocalDraft?> getDraft(String id) async {
    final encrypted = await _storage.read(_formatKey(id));
    if (encrypted == null) return null;

    final decrypted = await _encryption.decrypt(encrypted);
    final json = jsonDecode(decrypted) as Map<String, dynamic>;
    return LocalDraft.fromJson(json);
  }

  Future<List<LocalDraft>> listDrafts({String? draftType}) async {
    final allEntries = await _storage.readAll();
    final drafts = <LocalDraft>[];

    for (final entry in allEntries.entries) {
      if (entry.key.startsWith(_draftPrefix)) {
        try {
          final decrypted = await _encryption.decrypt(entry.value);
          final json = jsonDecode(decrypted) as Map<String, dynamic>;
          final draft = LocalDraft.fromJson(json);
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

  Future<void> deleteDraft(String id) async {
    await _storage.delete(_formatKey(id));
  }

  Future<void> markConflict(String id, Map<String, dynamic> serverData) async {
    final draft = await getDraft(id);
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
