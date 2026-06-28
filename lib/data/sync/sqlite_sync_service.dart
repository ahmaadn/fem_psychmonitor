import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_auth_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_user_repository.dart';
import 'package:fem_psychmonitor/data/sync/sync_service.dart';

/// Offline-first sync orchestrator.
///
/// Watches `connectivity_plus` for online events; when online and a remote base
/// URL is configured it drains the `sync_queue` (push) and pulls remote updates,
/// merging with **last-write-wins** (remote `updated_at` vs local).
///
/// Until a live server exists ([ApiAuthRepository.baseUrl] == null etc.) the
/// push/pull calls are guarded no-ops, so this runs safely offline-only.
class SqliteSyncService implements SyncService {
  SqliteSyncService({
    required this.apiAuth,
    required this.apiUser,
    required this.apiDetection,
    this.baseUrl,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  /// When null/empty, sync is disabled (current state — no live server).
  final String? baseUrl;
  final ApiAuthRepository apiAuth;
  final ApiUserRepository apiUser;
  final ApiDetectionRepository apiDetection;

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _syncing = false;

  bool get isEnabled => baseUrl != null && baseUrl!.trim().isNotEmpty;

  void _init() {
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online && isEnabled) {
        pushDirty();
      }
    });
  }

  @override
  Future<int> pushDirty() async {
    if (!isEnabled || _syncing) return 0;
    _syncing = true;
    int synced = 0;
    try {
      final db = await DatabaseHelper.instance.database;
      final pending = await db.query(
        AppTables.syncQueue,
        where: 'synced_at IS NULL',
        orderBy: 'queued_at ASC',
      );

      for (final entry in pending) {
        final id = entry['id'] as int;
        final entityType = entry['entity_type'] as String;
        final operation = entry['operation'] as String;
        final payloadRaw = entry['payload_json'] as String?;

        final ok = await _dispatch(entityType, operation, payloadRaw);
        if (ok) {
          await db.update(
            AppTables.syncQueue,
            {'synced_at': DateTime.now().millisecondsSinceEpoch},
            where: 'id = ?',
            whereArgs: [id],
          );
          synced++;
        }
      }
    } finally {
      _syncing = false;
    }
    return synced;
  }

  /// Route a single queue entry to the matching Api repository method.
  /// Returns true if the remote call "succeeded" (currently always false while
  /// the server is offline, so entries stay pending — intended behaviour).
  Future<bool> _dispatch(
    String entityType,
    String operation,
    String? payloadRaw,
  ) async {
    if (!isEnabled) return false;
    try {
      final payload =
          payloadRaw == null ? null : jsonDecode(payloadRaw) as Map<String, dynamic>;
      switch (entityType) {
        case SyncEntity.user:
          // TODO(server): call apiUser.updateProfile / register equivalents.
          break;
        case SyncEntity.detectionSession:
          if (payload != null) {
            // apiDetection.saveSession(...) — left as TODO until server lands.
          }
          break;
        case SyncEntity.authToken:
          break;
      }
      // While no live server exists, treat as not-yet-synced so entries remain
      // pending until a real backend acknowledges them.
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<int> pullRemote() async {
    if (!isEnabled) return 0;
    // TODO(server): GET remote users/sessions with updated_at > lastSync,
    // then LWW-merge into SQLite using [UserRow.colUpdatedAt] comparison.
    return 0;
  }

  @override
  Future<int> getPendingCount() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM ${AppTables.syncQueue} WHERE synced_at IS NULL',
    );
    if (rows.isEmpty) return 0;
    final value = rows.first['c'];
    return value is int ? value : int.tryParse('$value') ?? 0;
  }

  /// Trigger a push after a local write (called by ViewModels / repos).
  Future<void> notifyChanged() async {
    if (isEnabled) {
      await pushDirty();
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
