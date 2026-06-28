import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/local/tables/user_row.dart';

/// Mixin providing the cross-cutting "enqueue to sync_queue" behaviour shared
/// by every Sqlite repo write method.
///
/// Per the architecture, every write must (a) flag the touched row dirty and
/// (b) enqueue a `sync_queue` entry so the [SyncService] can push it later.
mixin SyncQueueHelper {
  /// Enqueue a sync entry. [payloadJson] is the serialised entity state to ship
  /// to the remote API.
  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required SyncOperation operation,
    String? payloadJson,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      AppTables.syncQueue,
      SyncQueueEntry(
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        payloadJson: payloadJson,
        queuedAt: DateTime.now(),
      ).toRow(),
    );
  }

  /// Mark a row dirty in its own table (generic column `is_dirty`).
  Future<void> markDirty(String table, String idColumn, String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      table,
      {
        'is_dirty': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: '$idColumn = ?',
      whereArgs: [id],
    );
  }
}
