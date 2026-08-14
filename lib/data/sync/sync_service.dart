/// Contract for the offline-first sync orchestration (US-scaffold).
///
/// Every Sqlite write enqueues a `sync_queue` entry flagged dirty. When
/// connectivity returns and a real API base URL is configured, the
/// [SyncService] pushes dirty records via the `Api*Repository` and pulls
/// remote updates, merging with **last-write-wins** (remote `updated_at` vs
/// local).
///
/// Until a live server exists, [pushDirty] / [pullRemote] are guarded no-ops.
abstract class SyncService {
  Future<int> synchronize();

  /// Push all pending (unsynced) queue entries to the remote API.
  /// Returns the number of entries successfully synced.
  Future<int> pushDirty();

  /// Pull remote updates since the last sync and merge into local SQLite
  /// (last-write-wins). Returns the number of records updated locally.
  Future<int> pullRemote();

  /// Number of entries still pending in the sync queue.
  Future<int> getPendingCount();
}
