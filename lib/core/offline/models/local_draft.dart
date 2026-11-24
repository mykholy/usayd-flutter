import 'sync_status.dart';

class LocalDraft {
  final String id;
  final String draftType;
  final Map<String, dynamic> data;
  final SyncStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? conflictData;

  const LocalDraft({
    required this.id,
    required this.draftType,
    required this.data,
    this.status = SyncStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.conflictData,
  });

  LocalDraft copyWith({
    String? id,
    String? draftType,
    Map<String, dynamic>? data,
    SyncStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? conflictData,
  }) {
    return LocalDraft(
      id: id ?? this.id,
      draftType: draftType ?? this.draftType,
      data: data ?? this.data,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      conflictData: conflictData ?? this.conflictData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'draft_type': draftType,
      'data': data,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'conflict_data': conflictData,
    };
  }

  factory LocalDraft.fromJson(Map<String, dynamic> json) {
    return LocalDraft(
      id: json['id'] as String,
      draftType: json['draft_type'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      status: SyncStatus.fromString(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      conflictData: json['conflict_data'] != null
          ? Map<String, dynamic>.from(json['conflict_data'] as Map)
          : null,
    );
  }
}
