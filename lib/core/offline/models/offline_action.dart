import 'sync_status.dart';

class OfflineAction {
  final String id;
  final String userId;
  final String endpoint;
  final String method;
  final Map<String, dynamic> payload;
  final Map<String, String>? headers;
  final SyncStatus status;
  final String idempotencyKey;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final String? errorMessage;
  final int retryCount;
  final Map<String, dynamic>? conflictDetails;

  const OfflineAction({
    required this.id,
    this.userId = 'default_user',
    required this.endpoint,
    required this.method,
    required this.payload,
    this.headers,
    this.status = SyncStatus.pending,
    required this.idempotencyKey,
    required this.createdAt,
    this.syncedAt,
    this.errorMessage,
    this.retryCount = 0,
    this.conflictDetails,
  });

  OfflineAction copyWith({
    String? id,
    String? userId,
    String? endpoint,
    String? method,
    Map<String, dynamic>? payload,
    Map<String, String>? headers,
    SyncStatus? status,
    String? idempotencyKey,
    DateTime? createdAt,
    DateTime? syncedAt,
    String? errorMessage,
    int? retryCount,
    Map<String, dynamic>? conflictDetails,
  }) {
    return OfflineAction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      payload: payload ?? this.payload,
      headers: headers ?? this.headers,
      status: status ?? this.status,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      conflictDetails: conflictDetails ?? this.conflictDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'endpoint': endpoint,
      'method': method,
      'payload': payload,
      'headers': headers,
      'status': status.name,
      'idempotency_key': idempotencyKey,
      'created_at': createdAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'error_message': errorMessage,
      'retry_count': retryCount,
      'conflict_details': conflictDetails,
    };
  }

  factory OfflineAction.fromJson(Map<String, dynamic> json) {
    return OfflineAction(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? 'default_user',
      endpoint: json['endpoint'] as String,
      method: json['method'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      headers: json['headers'] != null
          ? Map<String, String>.from(json['headers'] as Map)
          : null,
      status: SyncStatus.fromString(json['status'] as String? ?? 'pending'),
      idempotencyKey: json['idempotency_key'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
      errorMessage: json['error_message'] as String?,
      retryCount: (json['retry_count'] as num?)?.toInt() ?? 0,
      conflictDetails: json['conflict_details'] != null
          ? Map<String, dynamic>.from(json['conflict_details'] as Map)
          : null,
    );
  }
}
