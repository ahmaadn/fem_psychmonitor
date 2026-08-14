import 'dart:async';

import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/calendar_day_summary.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/models/emotion_summary_model.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/sqlite/sqlite_detection_repository.dart';
import 'package:fem_psychmonitor/data/sync/sqlite_sync_service.dart';

class HybridDetectionRepository extends DetectionRepository {
  HybridDetectionRepository({
    required SqliteDetectionRepository local,
    required SqliteSyncService sync,
  }) : _local = local,
       _sync = sync;

  final SqliteDetectionRepository _local;
  final SqliteSyncService _sync;

  @override
  Future<List<DetectionSessionModel>> getSessionHistory({
    int limit = 20,
    int offset = 0,
    int? filterDays,
    DateTime? startedOnDate,
  }) {
    return _local.getSessionHistory(
      limit: limit,
      offset: offset,
      filterDays: filterDays,
      startedOnDate: startedOnDate,
    );
  }

  @override
  Future<DetectionSessionModel?> getSessionById(String id) {
    return _local.getSessionById(id);
  }

  @override
  Future<DetectionSessionModel> saveSession(
    DetectionSessionModel session,
  ) async {
    final saved = await _local.saveSession(session);
    unawaited(_sync.synchronize());
    return saved;
  }

  @override
  Future<Map<DateTime, EmotionLabelType>> getCalendarEmotions(
    int year,
    int month,
  ) {
    return _local.getCalendarEmotions(year, month);
  }

  @override
  Future<Map<DateTime, CalendarDaySummary>> getCalendarSummaries({
    required int year,
    required int month,
  }) {
    return _local.getCalendarSummaries(year: year, month: month);
  }

  @override
  Future<HomeStats> getHomeStats() => _local.getHomeStats();

  @override
  Future<DetectionSessionModel> correctEmotion(
    String sessionId,
    EmotionLabelType newLabel,
  ) async {
    final saved = await _local.correctEmotion(sessionId, newLabel);
    unawaited(_sync.synchronize());
    return saved;
  }

  @override
  Future<DetectionSessionModel> updateNote(
    String sessionId,
    String? note,
  ) async {
    final saved = await _local.updateNote(sessionId, note);
    unawaited(_sync.synchronize());
    return saved;
  }

  @override
  Future<Map<EmotionLabelType, int>> getWeeklyChart() {
    return _local.getWeeklyChart();
  }

  @override
  Future<List<EmotionSeriesPoint>> getChartSeries({int days = 7}) {
    return _local.getChartSeries(days: days);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _local.deleteSession(sessionId);
    unawaited(_sync.synchronize());
  }
}
