import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
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

  /// Get aggregated stats for the home screen.
  Future<HomeStats> getHomeStats();

  /// ── US-17: Koreksi Hasil ──────────────────────────────────────────────
  /// Replace a session's dominant emotion label with a user-corrected value.
  /// Returns the updated session.
  Future<DetectionSessionModel> correctEmotion(
    String sessionId,
    EmotionLabelType newLabel,
  );

  /// ── US-18: weekly summary for the analysis-result hotline card ────────
  /// Returns a short week-long emotion distribution (counts per label, for
  /// the last 7 days including today).
  Future<Map<EmotionLabelType, int>> getWeeklyChart();

  /// ── US-19: time-series for the history line/bar chart ─────────────────
  /// Returns one [EmotionSeriesPoint] per day over [days] days (default 7),
  /// each carrying the count of sessions whose display emotion matches.
  Future<List<EmotionSeriesPoint>> getChartSeries({int days = 7});
}

/// A single bucket in a history chart series (US-19).
class EmotionSeriesPoint {
  final DateTime date;
  final Map<EmotionLabelType, int> counts;

  const EmotionSeriesPoint({required this.date, required this.counts});

  int get total => counts.values.fold(0, (a, b) => a + b);
}
