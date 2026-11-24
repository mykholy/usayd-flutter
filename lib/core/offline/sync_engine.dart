import 'dart:async';
import 'package:http/http.dart' as http;
import '../network/api_client.dart';
import '../network/problem_details_exception.dart';
import 'models/offline_action.dart';
import 'models/sync_status.dart';
import 'offline_queue.dart';

enum SyncEventType {
  started,
  actionSynced,
  actionConflict,
  actionFailed,
  actionRetried,
  completed,
}

class SyncEvent {
  final SyncEventType type;
  final OfflineAction? action;
  final String? message;
  final DateTime timestamp;

  SyncEvent({
    required this.type,
    this.action,
    this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class SyncResult {
  final int syncedCount;
  final int conflictCount;
  final int failedCount;
  final int retryCount;

  const SyncResult({
    required this.syncedCount,
    required this.conflictCount,
    required this.failedCount,
    required this.retryCount,
  });

  bool get hasConflicts => conflictCount > 0;
  bool get isCleanSuccess =>
      conflictCount == 0 && failedCount == 0 && retryCount == 0;
}

class OfflineSyncEngine {
  final OfflineActionQueue queue;
  final ApiClient apiClient;
  final int maxRetries;

  bool _isSyncing = false;
  Future<SyncResult>? _activeSyncFuture;
  final StreamController<SyncEvent> _eventController =
      StreamController<SyncEvent>.broadcast();

  OfflineSyncEngine({
    required this.queue,
    required this.apiClient,
    this.maxRetries = 3,
  });

  bool get isSyncing => _isSyncing;
  Stream<SyncEvent> get eventStream => _eventController.stream;

  /// Recover any actions stuck in syncing state from previous ungraceful shutdown.
  Future<int> recoverAbandonedSyncing({String? currentUserId}) async {
    return queue.recoverStuckSyncing(userId: currentUserId);
  }

  /// Single-flight sync: returns the active in-flight future if already synchronizing.
  Future<SyncResult> syncAll({String? currentUserId}) {
    if (_activeSyncFuture != null) {
      return _activeSyncFuture!;
    }

    _activeSyncFuture = _executeSync(currentUserId: currentUserId);
    return _activeSyncFuture!.whenComplete(() {
      _activeSyncFuture = null;
    });
  }

  Future<SyncResult> _executeSync({String? currentUserId}) async {
    _isSyncing = true;
    _eventController.add(SyncEvent(type: SyncEventType.started));

    int syncedCount = 0;
    int conflictCount = 0;
    int failedCount = 0;
    int retryCount = 0;

    try {
      // Recover any unclosed syncing actions first
      await queue.recoverStuckSyncing(userId: currentUserId);

      final pendingActions = await queue.getPendingActions(
        userId: currentUserId,
      );

      for (final action in pendingActions) {
        // Guard: account isolation validation
        if (currentUserId != null && action.userId != currentUserId) {
          _eventController.add(
            SyncEvent(
              type: SyncEventType.actionFailed,
              action: action,
              message:
                  'Skipped action belonging to another user: ${action.userId}',
            ),
          );
          continue;
        }

        // Mark in-flight
        final inFlight = action.copyWith(status: SyncStatus.syncing);
        await queue.updateAction(inFlight);

        try {
          final headers = <String, String>{
            'Idempotency-Key': action.idempotencyKey,
          };
          if (action.headers != null) {
            headers.addAll(action.headers!);
          }

          await apiClient.request(
            method: action.method,
            path: action.endpoint,
            body: action.payload,
            headers: headers,
          );

          // Success: 2xx confirmed by backend
          final synced = inFlight.copyWith(
            status: SyncStatus.synced,
            syncedAt: DateTime.now(),
            errorMessage: null,
          );
          await queue.updateAction(synced);
          syncedCount++;
          _eventController.add(
            SyncEvent(type: SyncEventType.actionSynced, action: synced),
          );
        } on ProblemDetailsException catch (e) {
          if (e.status == 409) {
            // Conflict: state divergence between client draft and server truth
            final conflictAction = inFlight.copyWith(
              status: SyncStatus.conflict,
              errorMessage: e.detail,
              conflictDetails: e.extensions,
            );
            await queue.updateAction(conflictAction);
            conflictCount++;
            _eventController.add(
              SyncEvent(
                type: SyncEventType.actionConflict,
                action: conflictAction,
                message: e.detail,
              ),
            );
          } else if (e.status == 429) {
            // HTTP 429 Rate Limited: handle gracefully with backoff
            final retryAfterSeconds = _parseRetryAfter(e);
            final retriedAction = inFlight.copyWith(
              status: SyncStatus.pending,
              retryCount: inFlight.retryCount + 1,
              errorMessage:
                  'Rate limited (HTTP 429). Retry after ${retryAfterSeconds}s',
            );
            await queue.updateAction(retriedAction);
            retryCount++;
            _eventController.add(
              SyncEvent(
                type: SyncEventType.actionRetried,
                action: retriedAction,
                message: 'Rate limited. Retry after ${retryAfterSeconds}s',
              ),
            );
            break; // Pause remaining sync batch
          } else if (e.status >= 400 && e.status < 500) {
            // Unrecoverable client error
            final failedAction = inFlight.copyWith(
              status: SyncStatus.failed,
              errorMessage: e.detail,
            );
            await queue.updateAction(failedAction);
            failedCount++;
            _eventController.add(
              SyncEvent(
                type: SyncEventType.actionFailed,
                action: failedAction,
                message: e.detail,
              ),
            );
          } else {
            // Server error (5xx): transient, preserve for retry
            final retriedAction = inFlight.copyWith(
              status: SyncStatus.pending,
              retryCount: inFlight.retryCount + 1,
              errorMessage: e.detail,
            );
            await queue.updateAction(retriedAction);
            retryCount++;
            _eventController.add(
              SyncEvent(
                type: SyncEventType.actionRetried,
                action: retriedAction,
                message: e.detail,
              ),
            );
          }
        } on http.ClientException catch (e) {
          // Network partition: preserve pending for next sync
          final retriedAction = inFlight.copyWith(
            status: SyncStatus.pending,
            retryCount: inFlight.retryCount + 1,
            errorMessage: e.message,
          );
          await queue.updateAction(retriedAction);
          retryCount++;
          _eventController.add(
            SyncEvent(
              type: SyncEventType.actionRetried,
              action: retriedAction,
              message: e.message,
            ),
          );
        } catch (e) {
          final retriedAction = inFlight.copyWith(
            status: SyncStatus.pending,
            retryCount: inFlight.retryCount + 1,
            errorMessage: e.toString(),
          );
          await queue.updateAction(retriedAction);
          retryCount++;
          _eventController.add(
            SyncEvent(
              type: SyncEventType.actionRetried,
              action: retriedAction,
              message: e.toString(),
            ),
          );
        }
      }
    } finally {
      _isSyncing = false;
      _eventController.add(SyncEvent(type: SyncEventType.completed));
    }

    return SyncResult(
      syncedCount: syncedCount,
      conflictCount: conflictCount,
      failedCount: failedCount,
      retryCount: retryCount,
    );
  }

  int _parseRetryAfter(ProblemDetailsException e) {
    final val = e.extensions['retry_after'];
    if (val != null) {
      if (val is num) return val.toInt();
      if (val is String) {
        final parsed = int.tryParse(val);
        if (parsed != null) return parsed;
      }
    }
    return 30; // Default 30s backoff
  }

  void dispose() {
    _eventController.close();
  }
}
