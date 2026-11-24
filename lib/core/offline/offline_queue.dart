import 'dart:convert';
import 'encryption/encryption_service.dart';
import 'models/offline_action.dart';
import 'models/sync_status.dart';
import 'storage/offline_storage.dart';

class OfflineActionQueue {
  static const String _actionPrefix = 'offline_act_';

  final OfflineStorage _storage;
  final EncryptionService _encryption;

  OfflineActionQueue({
    required OfflineStorage storage,
    required EncryptionService encryption,
  }) : _storage = storage,
       _encryption = encryption;

  String _formatKey(String id) => '$_actionPrefix$id';

  /// Enqueue an action. Returns the persisted action.
  /// If an action with the same idempotencyKey already exists, returns the existing action (deduplication).
  Future<OfflineAction> enqueue(OfflineAction action) async {
    final existingActions = await getAllActions();
    for (final existing in existingActions) {
      if (existing.idempotencyKey == action.idempotencyKey) {
        return existing;
      }
    }

    final jsonString = jsonEncode(action.toJson());
    final encrypted = await _encryption.encrypt(jsonString);
    await _storage.write(_formatKey(action.id), encrypted);
    return action;
  }

  /// Retrieve all pending actions ordered by creation time ascending (FIFO).
  Future<List<OfflineAction>> getPendingActions() async {
    final all = await getAllActions();
    final pending = all
        .where(
          (a) =>
              a.status == SyncStatus.pending || a.status == SyncStatus.syncing,
        )
        .toList();
    pending.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return pending;
  }

  /// Retrieve all stored actions regardless of status.
  Future<List<OfflineAction>> getAllActions() async {
    final allEntries = await _storage.readAll();
    final actions = <OfflineAction>[];

    for (final entry in allEntries.entries) {
      if (entry.key.startsWith(_actionPrefix)) {
        try {
          final decrypted = await _encryption.decrypt(entry.value);
          final json = jsonDecode(decrypted) as Map<String, dynamic>;
          actions.add(OfflineAction.fromJson(json));
        } catch (_) {
          // If corruption occurs on an item, continue scanning remaining items
        }
      }
    }

    actions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return actions;
  }

  Future<OfflineAction?> getAction(String id) async {
    final encrypted = await _storage.read(_formatKey(id));
    if (encrypted == null) return null;

    final decrypted = await _encryption.decrypt(encrypted);
    final json = jsonDecode(decrypted) as Map<String, dynamic>;
    return OfflineAction.fromJson(json);
  }

  Future<void> updateAction(OfflineAction action) async {
    final jsonString = jsonEncode(action.toJson());
    final encrypted = await _encryption.encrypt(jsonString);
    await _storage.write(_formatKey(action.id), encrypted);
  }

  Future<void> removeAction(String id) async {
    await _storage.delete(_formatKey(id));
  }

  Future<void> clearSynced() async {
    final actions = await getAllActions();
    for (final action in actions) {
      if (action.status == SyncStatus.synced) {
        await removeAction(action.id);
      }
    }
  }

  Future<int> getPendingCount() async {
    final actions = await getAllActions();
    return actions
        .where(
          (a) =>
              a.status == SyncStatus.pending || a.status == SyncStatus.syncing,
        )
        .length;
  }

  Future<int> getConflictCount() async {
    final actions = await getAllActions();
    return actions.where((a) => a.status == SyncStatus.conflict).length;
  }
}
