import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/local/tables/detection_row.dart';
import 'package:fem_psychmonitor/data/local/tables/user_row.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_auth_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_daily_mood_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_user_repository.dart';
import 'package:fem_psychmonitor/data/sync/sync_service.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class SqliteSyncService implements SyncService {
  SqliteSyncService({
    required this.apiAuth,
    required this.apiUser,
    required this.apiDetection,
    required this.apiDailyMood,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity() {
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        unawaited(synchronize());
      }
    });
  }

  final ApiAuthRepository apiAuth;
  final ApiUserRepository apiUser;
  final ApiDetectionRepository apiDetection;
  final ApiDailyMoodRepository apiDailyMood;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Future<int>? _activeSync;

  bool get isEnabled => apiAuth.isEnabled;

  @override
  Future<int> synchronize() {
    return _activeSync ??= _synchronize().whenComplete(
      () => _activeSync = null,
    );
  }

  Future<int> _synchronize() async {
    if (!isEnabled || !apiAuth.hasRemoteSession) return 0;
    final pushed = await pushDirty();
    final pulled = await pullRemote();
    return pushed + pulled;
  }

  @override
  Future<int> pushDirty() async {
    if (!isEnabled || !apiAuth.hasRemoteSession) return 0;
    try {
      final db = await DatabaseHelper.instance.database;
      final pending = await db.query(
        AppTables.syncQueue,
        where: 'synced_at IS NULL',
        orderBy: 'queued_at ASC, id ASC',
      );
      var synced = 0;
      for (final entry in pending) {
        final queueId = entry['id'] as int;
        final entityType = entry['entity_type'] as String;
        final entityId = entry['entity_id'] as String;
        final operation = SyncOperationX.parse(entry['operation'] as String);
        final acknowledged = await _dispatch(
          entityType: entityType,
          entityId: entityId,
          operation: operation,
        );
        if (!acknowledged) continue;
        await db.update(
          AppTables.syncQueue,
          {'synced_at': DateTime.now().millisecondsSinceEpoch},
          where: 'id = ?',
          whereArgs: [queueId],
        );
        await _clearDirtyIfLatest(
          db,
          queueId: queueId,
          entityType: entityType,
          entityId: entityId,
        );
        synced++;
      }
      return synced;
    } catch (error, stackTrace) {
      debugPrint('[sync] push failed: $error\n$stackTrace');
      return 0;
    }
  }

  Future<bool> _dispatch({
    required String entityType,
    required String entityId,
    required SyncOperation operation,
  }) async {
    try {
      switch (entityType) {
        case SyncEntity.user:
          return _pushUser(entityId, operation);
        case SyncEntity.detectionSession:
          return _pushSession(entityId, operation);
        case SyncEntity.dailyMood:
          return _pushDailyMood(entityId, operation);
        case SyncEntity.userDataReset:
          await apiAuth.resetUserData(entityId);
          return true;
        case SyncEntity.accountDelete:
          await apiAuth.deleteAccount(entityId);
          return true;
        default:
          debugPrint('[sync] unsupported entity: $entityType');
          return false;
      }
    } catch (error, stackTrace) {
      debugPrint(
        '[sync] $entityType/$entityId/${operation.name} failed: '
        '$error\n$stackTrace',
      );
      return false;
    }
  }

  Future<bool> _pushUser(String userId, SyncOperation operation) async {
    if (operation == SyncOperation.delete) {
      await apiAuth.deleteAccount(userId);
      return true;
    }
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      AppTables.users,
      where: '${UserRow.colId} = ? AND ${UserRow.colIsGuest} = 0',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) return true;
    final user = UserRow.toModel(rows.first);
    await apiUser.syncState(user);
    return true;
  }

  Future<bool> _pushDailyMood(String date, SyncOperation operation) async {
    if (operation == SyncOperation.delete) return true;
    final db = await DatabaseHelper.instance.database;
    final auth = await db.query(
      AppTables.authTokens,
      columns: [AuthTokenRow.colUserId],
      orderBy: '${AuthTokenRow.colIssuedAt} DESC',
      limit: 1,
    );
    if (auth.isEmpty) return false;
    final userId = auth.first[AuthTokenRow.colUserId] as String;
    final rows = await db.query(
      AppTables.dailyMoods,
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      limit: 1,
    );
    if (rows.isEmpty) return true;
    final emotion = EmotionLabelType.values.firstWhere(
      (value) => value.name == rows.first['emotion'],
      orElse: () => EmotionLabelType.neutral,
    );
    await apiDailyMood.upsert(date: date, emotion: emotion);
    return true;
  }

  Future<bool> _pushSession(String sessionId, SyncOperation operation) async {
    if (operation == SyncOperation.delete) {
      await apiDetection.deleteSession(sessionId);
      return true;
    }
    final session = await _loadLocalSession(sessionId);
    if (session == null) return true;
    if (session.userId == 'guest_local') return false;
    await apiDetection.saveSession(session);
    return true;
  }

  Future<DetectionSessionModel?> _loadLocalSession(String sessionId) async {
    final db = await DatabaseHelper.instance.database;
    final sessions = await db.query(
      AppTables.detectionSessions,
      where: '${DetectionSessionRow.colId} = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (sessions.isEmpty) return null;
    final results = await db.query(
      AppTables.detectionResults,
      where: '${DetectionResultRow.colSessionId} = ?',
      whereArgs: [sessionId],
      orderBy: '${DetectionResultRow.colStartSec} ASC',
    );
    return DetectionSessionRow.toModel(
      sessions.first,
      results: results.map(DetectionResultRow.toModel).toList(),
    );
  }

  Future<void> _clearDirtyIfLatest(
    Database db, {
    required int queueId,
    required String entityType,
    required String entityId,
  }) async {
    final newer =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM ${AppTables.syncQueue} '
            'WHERE entity_type = ? AND entity_id = ? '
            'AND synced_at IS NULL AND id > ?',
            [entityType, entityId, queueId],
          ),
        ) ??
        0;
    if (newer > 0) return;
    if (entityType == SyncEntity.user) {
      await db.update(
        AppTables.users,
        {UserRow.colIsDirty: 0},
        where: '${UserRow.colId} = ?',
        whereArgs: [entityId],
      );
    } else if (entityType == SyncEntity.detectionSession) {
      await db.update(
        AppTables.detectionSessions,
        {DetectionSessionRow.colIsDirty: 0},
        where: '${DetectionSessionRow.colId} = ?',
        whereArgs: [entityId],
      );
    }
  }

  @override
  Future<int> pullRemote() async {
    if (!isEnabled || !apiAuth.hasRemoteSession) return 0;
    try {
      final db = await DatabaseHelper.instance.database;
      final resetPending =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM ${AppTables.syncQueue} '
              'WHERE entity_type = ? AND synced_at IS NULL',
              [SyncEntity.userDataReset],
            ),
          ) ??
          0;
      if (resetPending > 0) return 0;
      final snapshot = await apiDetection.pullSince(
        apiAuth.sessionStore.syncCursor,
      );
      var merged = 0;
      await db.transaction((txn) async {
        for (final rawUser in snapshot.users) {
          merged += await _mergeUser(txn, rawUser);
        }
        for (final session in snapshot.sessions) {
          merged += await _mergeSession(txn, session);
        }
        for (final mood in snapshot.dailyMoods) {
          merged += await _mergeDailyMood(txn, mood);
        }
      });
      await apiAuth.sessionStore.saveSyncCursor(snapshot.serverTime);
      return merged;
    } catch (error, stackTrace) {
      debugPrint('[sync] pull failed: $error\n$stackTrace');
      return 0;
    }
  }

  Future<int> _mergeUser(Transaction txn, Map<String, dynamic> rawUser) async {
    final id = rawUser['id'] as String;
    final local = await txn.query(
      AppTables.users,
      where: '${UserRow.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (local.isEmpty || (local.first[UserRow.colIsDirty] as int? ?? 0) == 1) {
      return 0;
    }
    final user = userFromServer(rawUser);
    final hash = local.first[UserRow.colPasswordHash] as String;
    await txn.update(
      AppTables.users,
      UserRow.toRow(user, passwordHash: hash, isDirty: false),
      where: '${UserRow.colId} = ?',
      whereArgs: [id],
    );
    return 1;
  }

  Future<int> _mergeDailyMood(Transaction txn, RemoteDailyMood mood) async {
    final pending =
        Sqflite.firstIntValue(
          await txn.rawQuery(
            'SELECT COUNT(*) FROM ${AppTables.syncQueue} '
            'WHERE entity_type = ? AND entity_id = ? AND synced_at IS NULL',
            [SyncEntity.dailyMood, mood.date],
          ),
        ) ??
        0;
    if (pending > 0) return 0;
    await txn.insert(AppTables.dailyMoods, {
      'user_id': mood.userId,
      'date': mood.date,
      'emotion': mood.emotion.name,
      'created_at': mood.createdAt,
      'updated_at': mood.updatedAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return 1;
  }

  Future<int> _mergeSession(
    Transaction txn,
    DetectionSessionModel session,
  ) async {
    final pending =
        Sqflite.firstIntValue(
          await txn.rawQuery(
            'SELECT COUNT(*) FROM ${AppTables.syncQueue} '
            'WHERE entity_type = ? AND entity_id = ? AND synced_at IS NULL',
            [SyncEntity.detectionSession, session.id],
          ),
        ) ??
        0;
    if (pending > 0) return 0;

    final existing = await txn.query(
      AppTables.detectionSessions,
      columns: [DetectionSessionRow.colCreatedAt],
      where: '${DetectionSessionRow.colId} = ?',
      whereArgs: [session.id],
      limit: 1,
    );
    final now = DateTime.now().millisecondsSinceEpoch;
    await txn.insert(
      AppTables.detectionSessions,
      DetectionSessionRow.toRow(
        session,
        createdAt: existing.isEmpty
            ? now
            : existing.first[DetectionSessionRow.colCreatedAt] as int,
        updatedAt: now,
        isDirty: false,
      ),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await txn.delete(
      AppTables.detectionResults,
      where: '${DetectionResultRow.colSessionId} = ?',
      whereArgs: [session.id],
    );
    for (final result in session.results) {
      await txn.insert(
        AppTables.detectionResults,
        DetectionResultRow.toRow(result),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return 1;
  }

  @override
  Future<int> getPendingCount() async {
    try {
      final db = await DatabaseHelper.instance.database;
      return Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM ${AppTables.syncQueue} '
              'WHERE synced_at IS NULL',
            ),
          ) ??
          0;
    } catch (error) {
      debugPrint('[sync] pending count failed: $error');
      return 0;
    }
  }

  Future<void> notifyChanged() async {
    await synchronize();
  }

  void dispose() {
    unawaited(_sub?.cancel());
  }
}
