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

  String _formatKey(String userId, String id) => '$_actionPrefix${userId}_$id';

  /// Enqueue an action scoped by user. Returns the persisted action.
  /// If an action with the same idempotencyKey already exists, returns the existing action (deduplication).
  Future<OfflineAction> enqueue(OfflineAction action) async {
    final existingActions = await getAllActions(userId: action.userId);
    for (final existing in existingActions) {
      if (existing.idempotencyKey == action.idempotencyKey) {
        return existing;
      }
    }

    final jsonString = jsonEncode(action.toJson());
    final encrypted = await _encryption.encrypt(jsonString);
    await _storage.write(_formatKey(action.userId, action.id), encrypted);
    return action;
  }

  /// Retrieve all pending actions ordered by creation time ascending (FIFO).
  Future<List<OfflineAction>> getPendingActions({
    required String userId,
  }) async {
    final all = await getAllActions(userId: userId);
    final pending = all.where((a) => a.status == SyncStatus.pending).toList();
    pending.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return pending;
  }

  /// Retrieve all stored actions, for the specified userId.
  Future<List<OfflineAction>> getAllActions({required String userId}) async {
    final allEntries = await _storage.readAll();
    final actions = <OfflineAction>[];

    for (final entry in allEntries.entries) {
      if (entry.key.startsWith(_actionPrefix)) {
        try {
          final decrypted = await _encryption.decrypt(entry.value);
          final json = jsonDecode(decrypted) as Map<String, dynamic>;
          final action = OfflineAction.fromJson(json);
          if (action.userId == userId) {
            actions.add(action);
          }
        } catch (_) {
          // If corruption occurs on an item, continue scanning remaining items
        }
      }
    }

    actions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return actions;
  }

  Future<OfflineAction?> getAction(String id, {required String userId}) async {
    final encrypted = await _storage.read(_formatKey(userId, id));
    if (encrypted == null) return null;
    final decrypted = await _encryption.decrypt(encrypted);
    final json = jsonDecode(decrypted) as Map<String, dynamic>;
    final action = OfflineAction.fromJson(json);
    return action.userId == userId && action.id == id ? action : null;
  }

  Future<void> updateAction(OfflineAction action) async {
    final jsonString = jsonEncode(action.toJson());
    final encrypted = await _encryption.encrypt(jsonString);
    await _storage.write(_formatKey(action.userId, action.id), encrypted);
  }

  Future<void> removeAction(String id, {required String userId}) async {
    if (await getAction(id, userId: userId) != null) {
      await _storage.delete(_formatKey(userId, id));
    }
  }

  Future<void> clearSynced({required String userId}) async {
    final actions = await getAllActions(userId: userId);
    for (final action in actions) {
      if (action.status == SyncStatus.synced) {
        await removeAction(action.id, userId: action.userId);
      }
    }
  }

  Future<int> getPendingCount({required String userId}) async {
    final pending = await getPendingActions(userId: userId);
    return pending.length;
  }

  Future<int> getConflictCount({required String userId}) async {
    final actions = await getAllActions(userId: userId);
    return actions.where((a) => a.status == SyncStatus.conflict).length;
  }

  /// Quarantine interrupted writes until server reconciliation is possible.
  Future<int> recoverStuckSyncing({required String userId}) async {
    final all = await getAllActions(userId: userId);
    int recovered = 0;
    for (final action in all) {
      if (action.status == SyncStatus.syncing) {
        final updated = action.copyWith(
          status: SyncStatus.conflict,
          errorMessage: 'Interrupted sync requires reconciliation.',
        );
        await updateAction(updated);
        recovered++;
      }
    }
    return recovered;
  }
}
