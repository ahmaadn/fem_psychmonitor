import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/sync_queue_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/local/tables/detection_row.dart';
import 'package:fem_psychmonitor/data/local/tables/user_row.dart';
import 'package:fem_psychmonitor/data/models/detection_result_model.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/models/emotion_summary_model.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:sqflite/sqflite.dart';

/// Offline-first detection-session repository backed by SQLite.
///
/// All writes persist locally immediately (offline works) and flag the row
/// dirty + enqueue a sync entry for later remote push.
class SqliteDetectionRepository extends DetectionRepository
    with SyncQueueHelper {
  @override
  Future<DetectionSessionModel> saveSession(
    DetectionSessionModel session,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      await txn.insert(
        AppTables.detectionSessions,
        DetectionSessionRow.toRow(
          session,
          createdAt: now,
          updatedAt: now,
          isDirty: true,
        ),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Replace existing results for this session.
      await txn.delete(
        AppTables.detectionResults,
        where: '${DetectionResultRow.colSessionId} = ?',
        whereArgs: [session.id],
      );

      final batch = txn.batch();
      for (final r in session.results) {
        batch.insert(
          AppTables.detectionResults,
          DetectionResultRow.toRow(r),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });

    await enqueue(
      entityType: SyncEntity.detectionSession,
      entityId: session.id,
      operation: SyncOperation.insert,
      payloadJson: syncPayloadJson(session.toJson()),
    );

    return session;
  }

  @override
  Future<DetectionSessionModel?> getSessionById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      AppTables.detectionSessions,
      where: '${DetectionSessionRow.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final results = await _loadResults(db, id);
    return DetectionSessionRow.toModel(rows.first, results: results);
  }

  @override
  Future<List<DetectionSessionModel>> getSessionHistory({
    int limit = 20,
    int offset = 0,
    int? filterDays,
    DateTime? startedOnDate,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final userId = await _currentUserId(db);
    if (userId == null) return [];

    final where = StringBuffer('${DetectionSessionRow.colUserId} = ?');
    final args = <Object?>[userId];
    if (filterDays != null) {
      final cutoff = DateTime.now().subtract(Duration(days: filterDays));
      where.write(' AND ${DetectionSessionRow.colStartedAt} >= ?');
      args.add(cutoff.millisecondsSinceEpoch);
    }
    if (startedOnDate != null) {
      final dayStart = DateTime(
        startedOnDate.year,
        startedOnDate.month,
        startedOnDate.day,
      );
      final nextDay = dayStart.add(const Duration(days: 1));
      where.write(' AND ${DetectionSessionRow.colStartedAt} >= ?');
      where.write(' AND ${DetectionSessionRow.colStartedAt} < ?');
      args.add(dayStart.millisecondsSinceEpoch);
      args.add(nextDay.millisecondsSinceEpoch);
    }

    final rows = await db.query(
      AppTables.detectionSessions,
      where: where.toString(),
      whereArgs: args,
      orderBy: '${DetectionSessionRow.colStartedAt} DESC',
      limit: limit,
      offset: offset,
    );

    final sessions = <DetectionSessionModel>[];
    for (final row in rows) {
      final results = await _loadResults(
        db,
        row[DetectionSessionRow.colId] as String,
      );
      sessions.add(DetectionSessionRow.toModel(row, results: results));
    }
    return sessions;
  }

  @override
  Future<Map<DateTime, EmotionLabelType>> getCalendarEmotions(
    int year,
    int month,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final userId = await _currentUserId(db);
    if (userId == null) return {};

    final monthStart = DateTime(year, month);
    final nextMonth = DateTime(year, month + 1);

    final rows = await db.query(
      AppTables.detectionSessions,
      columns: [
        DetectionSessionRow.colStartedAt,
        DetectionSessionRow.colDominantEmotion,
        DetectionSessionRow.colCorrectedEmotion,
      ],
      where:
          '${DetectionSessionRow.colUserId} = ? '
          'AND ${DetectionSessionRow.colStartedAt} >= ? '
          'AND ${DetectionSessionRow.colStartedAt} < ?',
      whereArgs: [
        userId,
        monthStart.millisecondsSinceEpoch,
        nextMonth.millisecondsSinceEpoch,
      ],
      orderBy: '${DetectionSessionRow.colStartedAt} ASC',
    );

    final data = <DateTime, EmotionLabelType>{};
    for (final row in rows) {
      final startedAt = DateTime.fromMillisecondsSinceEpoch(
        row[DetectionSessionRow.colStartedAt] as int,
      );
      final dateKey = DateTime(startedAt.year, startedAt.month, startedAt.day);
      final corrected = row[DetectionSessionRow.colCorrectedEmotion] as String?;
      final emotion = EmotionLabelType.values.firstWhere(
        (e) =>
            e.name ==
            (corrected ?? row[DetectionSessionRow.colDominantEmotion]),
        orElse: () => EmotionLabelType.neutral,
      );
      // Keep the most recent session's emotion per day.
      data[dateKey] = emotion;
    }
    return data;
  }

  @override
  Future<HomeStats> getHomeStats() async {
    final db = await DatabaseHelper.instance.database;
    final userId = await _currentUserId(db);

    final now = DateTime.now();
    // ISO week start (Monday).
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyCheckins = <DailyCheckIn>[];
    for (int i = 0; i < 7; i++) {
      final day = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day,
      ).add(Duration(days: i));
      final next = day.add(const Duration(days: 1));
      DailyCheckIn checkin = DailyCheckIn(date: day, isCheckedIn: false);
      if (userId != null) {
        final rows = await db.query(
          AppTables.detectionSessions,
          columns: [
            DetectionSessionRow.colDominantEmotion,
            DetectionSessionRow.colCorrectedEmotion,
          ],
          where:
              '${DetectionSessionRow.colUserId} = ? '
              'AND ${DetectionSessionRow.colStartedAt} >= ? '
              'AND ${DetectionSessionRow.colStartedAt} < ?',
          whereArgs: [
            userId,
            day.millisecondsSinceEpoch,
            next.millisecondsSinceEpoch,
          ],
          orderBy: '${DetectionSessionRow.colStartedAt} DESC',
          limit: 1,
        );
        if (rows.isNotEmpty) {
          final corrected =
              rows.first[DetectionSessionRow.colCorrectedEmotion] as String?;
          final emotion = EmotionLabelType.values.firstWhere(
            (e) =>
                e.name ==
                (corrected ??
                    rows.first[DetectionSessionRow.colDominantEmotion]),
            orElse: () => EmotionLabelType.neutral,
          );
          checkin = DailyCheckIn(
            date: day,
            isCheckedIn: true,
            dominantEmotion: emotion,
          );
        }
      }
      weeklyCheckins.add(checkin);
    }

    final streakDays = weeklyCheckins.where((c) => c.isCheckedIn).length;

    EmotionLabelType currentMood = EmotionLabelType.neutral;
    int currentMoodPercentage = 0;
    int totalRecordings = 0;
    String moodDescription = 'Belum ada deteksi. Mulai rekam suara pertamamu!';

    if (userId != null) {
      totalRecordings =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM ${AppTables.detectionSessions} '
              'WHERE ${DetectionSessionRow.colUserId} = ?',
              [userId],
            ),
          ) ??
          0;

      final recent = await db.query(
        AppTables.detectionSessions,
        where: '${DetectionSessionRow.colUserId} = ?',
        whereArgs: [userId],
        orderBy: '${DetectionSessionRow.colStartedAt} DESC',
        limit: 1,
      );
      if (recent.isNotEmpty) {
        final recentId = recent.first[DetectionSessionRow.colId] as String;
        final recentSession = DetectionSessionRow.toModel(
          recent.first,
          results: await _loadResults(db, recentId),
        );
        currentMood = recentSession.displayEmotion;
        currentMoodPercentage = (recentSession.displayConfidence * 100).round();
        moodDescription =
            'Berdasarkan analisis suara terakhir, kondisi emosionalmu terdeteksi.';
      } else {
        // US-03 empty state.
        moodDescription = 'Belum ada deteksi. Mulai rekam suara pertamamu!';
      }
    }

    return HomeStats(
      currentMood: currentMood,
      currentMoodPercentage: currentMoodPercentage,
      moodDescription: moodDescription,
      totalRecordings: totalRecordings,
      streakDays: streakDays,
      weeklyCheckins: weeklyCheckins,
      hasDetection: totalRecordings > 0,
    );
  }

  @override
  Future<DetectionSessionModel> correctEmotion(
    String sessionId,
    EmotionLabelType newLabel,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      AppTables.detectionSessions,
      {
        DetectionSessionRow.colCorrectedEmotion: newLabel.name,
        DetectionSessionRow.colUpdatedAt: now,
        DetectionSessionRow.colIsDirty: 1,
      },
      where: '${DetectionSessionRow.colId} = ?',
      whereArgs: [sessionId],
    );

    final rows = await db.query(
      AppTables.detectionSessions,
      where: '${DetectionSessionRow.colId} = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw Exception('Sesi tidak ditemukan: $sessionId');
    }
    final results = await _loadResults(db, sessionId);
    final updated = DetectionSessionRow.toModel(rows.first, results: results);

    await enqueue(
      entityType: SyncEntity.detectionSession,
      entityId: sessionId,
      operation: SyncOperation.update,
      payloadJson: syncPayloadJson(updated.toJson()),
    );

    return updated;
  }

  @override
  Future<DetectionSessionModel> updateNote(
    String sessionId,
    String? note,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final trimmed = note?.trim();
    await db.update(
      AppTables.detectionSessions,
      {
        DetectionSessionRow.colNote: (trimmed == null || trimmed.isEmpty)
            ? null
            : trimmed,
        DetectionSessionRow.colUpdatedAt: now,
        DetectionSessionRow.colIsDirty: 1,
      },
      where: '${DetectionSessionRow.colId} = ?',
      whereArgs: [sessionId],
    );

    final rows = await db.query(
      AppTables.detectionSessions,
      where: '${DetectionSessionRow.colId} = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw Exception('Sesi tidak ditemukan: $sessionId');
    }
    final results = await _loadResults(db, sessionId);
    final updated = DetectionSessionRow.toModel(rows.first, results: results);

    await enqueue(
      entityType: SyncEntity.detectionSession,
      entityId: sessionId,
      operation: SyncOperation.update,
      payloadJson: syncPayloadJson(updated.toJson()),
    );

    return updated;
  }

  @override
  Future<Map<EmotionLabelType, int>> getWeeklyChart() async {
    final db = await DatabaseHelper.instance.database;
    final userId = await _currentUserId(db);
    final counts = <EmotionLabelType, int>{
      for (final e in EmotionLabelType.values) e: 0,
    };
    if (userId == null) return counts;

    final cutoff = DateTime.now()
        .subtract(const Duration(days: 7))
        .millisecondsSinceEpoch;
    final rows = await db.query(
      AppTables.detectionSessions,
      columns: [
        DetectionSessionRow.colDominantEmotion,
        DetectionSessionRow.colCorrectedEmotion,
      ],
      where:
          '${DetectionSessionRow.colUserId} = ? '
          'AND ${DetectionSessionRow.colStartedAt} >= ?',
      whereArgs: [userId, cutoff],
    );
    for (final row in rows) {
      final corrected = row[DetectionSessionRow.colCorrectedEmotion] as String?;
      final emotion = EmotionLabelType.values.firstWhere(
        (e) =>
            e.name ==
            (corrected ?? row[DetectionSessionRow.colDominantEmotion]),
        orElse: () => EmotionLabelType.neutral,
      );
      counts[emotion] = (counts[emotion] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Future<List<EmotionSeriesPoint>> getChartSeries({int days = 7}) async {
    final db = await DatabaseHelper.instance.database;
    final userId = await _currentUserId(db);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final points = <EmotionSeriesPoint>[];

    for (int i = days - 1; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final next = day.add(const Duration(days: 1));
      final counts = <EmotionLabelType, int>{
        for (final e in EmotionLabelType.values) e: 0,
      };
      if (userId != null) {
        final rows = await db.query(
          AppTables.detectionSessions,
          columns: [
            DetectionSessionRow.colDominantEmotion,
            DetectionSessionRow.colCorrectedEmotion,
          ],
          where:
              '${DetectionSessionRow.colUserId} = ? '
              'AND ${DetectionSessionRow.colStartedAt} >= ? '
              'AND ${DetectionSessionRow.colStartedAt} < ?',
          whereArgs: [
            userId,
            day.millisecondsSinceEpoch,
            next.millisecondsSinceEpoch,
          ],
        );
        for (final row in rows) {
          final corrected =
              row[DetectionSessionRow.colCorrectedEmotion] as String?;
          final emotion = EmotionLabelType.values.firstWhere(
            (e) =>
                e.name ==
                (corrected ?? row[DetectionSessionRow.colDominantEmotion]),
            orElse: () => EmotionLabelType.neutral,
          );
          counts[emotion] = (counts[emotion] ?? 0) + 1;
        }
      }
      points.add(EmotionSeriesPoint(date: day, counts: counts));
    }
    return points;
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Future<String?> _currentUserId(Database db) async {
    final tokenRows = await db.query(
      AppTables.authTokens,
      orderBy: '${AuthTokenRow.colIssuedAt} DESC',
      limit: 1,
    );
    if (tokenRows.isEmpty) return null;
    return tokenRows.first[AuthTokenRow.colUserId] as String;
  }

  Future<List<DetectionResultModel>> _loadResults(
    Database db,
    String sessionId,
  ) async {
    final rows = await db.query(
      AppTables.detectionResults,
      where: '${DetectionResultRow.colSessionId} = ?',
      whereArgs: [sessionId],
      orderBy: '${DetectionResultRow.colStartSec} ASC',
    );
    return rows.map(DetectionResultRow.toModel).toList();
  }
}
