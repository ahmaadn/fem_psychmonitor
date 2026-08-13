import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/calendar_day_summary.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/models/emotion_summary_model.dart';

/// Contract for detection session data operations.
/// Implementations: DummyDetectionRepository, SqliteDetectionRepository,
/// ApiDetectionRepository
abstract class DetectionRepository {
  /// Get paginated session history, optionally filtered to the last
  /// [filterDays] days (US-11). When `filterDays` is null, no date filter is
  /// applied.
  Future<List<DetectionSessionModel>> getSessionHistory({
    int limit = 20,
    int offset = 0,
    int? filterDays,
    DateTime? startedOnDate,
  });

  /// Get a single session by its ID (with its result timeline loaded).
  Future<DetectionSessionModel?> getSessionById(String id);

  /// Persist a detection session (sessions + results) and flag it dirty.
  /// The optional [note] (US-09) and [audioFilePath] (US-15) are persisted on
  /// the session row.
  Future<DetectionSessionModel> saveSession(DetectionSessionModel session);

  /// Get emotion data for calendar view.
  Future<Map<DateTime, EmotionLabelType>> getCalendarEmotions(
    int year,
    int month,
  );

  /// Get per-day emotion summaries for calendar view.
  ///
  /// Default-implemented on top of [getCalendarEmotions] (loses the count
  /// detail). The SQLite override preserves [CalendarDaySummary.counts] for
  /// tile display — the calendar UI uses [CalendarDaySummary.dominant] for
  /// the emoji, but reads [CalendarDaySummary.dominantCount] / `.total` to
  /// show how decisive the dominant emotion was on that day.
  Future<Map<DateTime, CalendarDaySummary>> getCalendarSummaries({
    required int year,
    required int month,
  }) async {
    final labels = await getCalendarEmotions(year, month);
    return {
      for (final entry in labels.entries)
        entry.key: CalendarDaySummary(date: entry.key, counts: {entry.value: 1}),
    };
  }

  /// Get aggregated stats for the home screen.
  Future<HomeStats> getHomeStats();

  /// ── US-17: Koreksi Hasil ──────────────────────────────────────────────
  /// Replace a session's dominant emotion label with a user-corrected value.
  /// Returns the updated session.
  Future<DetectionSessionModel> correctEmotion(
    String sessionId,
    EmotionLabelType newLabel,
  );

  /// ── US-09: Catatan teks pribadi per sesi ──────────────────────────────
  /// Update the free-text [note] attached to a session. Returns the updated
  /// session. Persisting an empty/null note clears the field.
  Future<DetectionSessionModel> updateNote(String sessionId, String? note);

  /// ── US-18: weekly summary for the analysis-result hotline card ────────
  /// Returns a short week-long emotion distribution (counts per label, for
  /// the last 7 days including today).
  Future<Map<EmotionLabelType, int>> getWeeklyChart();

  /// ── US-19: time-series for the history line/bar chart ─────────────────
  /// Returns one [EmotionSeriesPoint] per day over [days] days (default 7),
  /// each carrying the count of sessions whose display emotion matches.
  Future<List<EmotionSeriesPoint>> getChartSeries({int days = 7});

  /// Delete a session and its results. Does **not** reverse mental score.
  Future<void> deleteSession(String sessionId);
}

/// A single bucket in a history chart series (US-19).
class EmotionSeriesPoint {
  final DateTime date;
  final Map<EmotionLabelType, int> counts;

  const EmotionSeriesPoint({required this.date, required this.counts});

  int get total => counts.values.fold(0, (a, b) => a + b);
}
