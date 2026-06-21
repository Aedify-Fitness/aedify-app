enum LibrarySyncStatus {
  neverSynced('never_synced'),
  syncing('syncing'),
  synced('synced'),
  failed('failed');

  final String value;
  const LibrarySyncStatus(this.value);

  static LibrarySyncStatus fromValue(String value) {
    return LibrarySyncStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => LibrarySyncStatus.neverSynced,
    );
  }
}
