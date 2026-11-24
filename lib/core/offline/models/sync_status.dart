enum SyncStatus {
  pending,
  syncing,
  synced,
  conflict,
  failed;

  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => SyncStatus.pending,
    );
  }
}
