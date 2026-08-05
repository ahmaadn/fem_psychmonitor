import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/calendar_day_summary.dart';
import 'package:fem_psychmonitor/data/models/detection_result_model.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/models/emotion_summary_model.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';

/// Dummy implementation with realistic mock data.
/// Replace with real SQLite/API implementation later.
class DummyDetectionRepository implements DetectionRepository {
  final List<DetectionSessionModel> _sessions = [];

  DummyDetectionRepository() {
    _sessions.addAll(_generateMockSessions());
  }

  @override
  Future<List<DetectionSessionModel>> getSessionHistory({
    int limit = 20,
    int offset = 0,
    int? filterDays,
    DateTime? startedOnDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var filtered = List<DetectionSessionModel>.from(_sessions);
    if (filterDays != null) {
      final cutoff = DateTime.now().subtract(Duration(days: filterDays));
      filtered = filtered.where((s) => s.startedAt.isAfter(cutoff)).toList();
    }
    if (startedOnDate != null) {
      filtered = filtered.where((s) {
        return s.startedAt.year == startedOnDate.year &&
            s.startedAt.month == startedOnDate.month &&
            s.startedAt.day == startedOnDate.day;
      }).toList();
    }
    final sorted = filtered..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final end = (offset + limit).clamp(0, sorted.length);
    if (offset >= sorted.length) return [];
    return sorted.sublist(offset, end);
  }

  @override
  Future<DetectionSessionModel?> getSessionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DetectionSessionModel> saveSession(
    DetectionSessionModel session,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Remove existing session with same id if any
    _sessions.removeWhere((s) => s.id == session.id);
    _sessions.add(session);
    return session;
  }

  @override
  Future<Map<DateTime, EmotionLabelType>> getCalendarEmotions(
    int year,
    int month,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final Map<DateTime, EmotionLabelType> data = {};
    for (final session in _sessions) {
      if (session.startedAt.year == year && session.startedAt.month == month) {
        final dateKey = DateTime(year, month, session.startedAt.day);
        data[dateKey] = session.displayEmotion;
      }
    }
    return data;
  }

  @override
  Future<Map<DateTime, CalendarDaySummary>> getCalendarSummaries({
    required int year,
    required int month,
  }) async {
    final Map<DateTime, Map<EmotionLabelType, int>> counts = {};
    for (final session in _sessions) {
      if (session.startedAt.year == year && session.startedAt.month == month) {
        final dateKey = DateTime(year, month, session.startedAt.day);
        final emotion = session.displayEmotion;
        counts
            .putIfAbsent(dateKey, () => {})
            .update(emotion, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    return {
      for (final e in counts.entries)
        e.key: CalendarDaySummary(date: e.key, counts: e.value),
    };
  }

  @override
  Future<HomeStats> getHomeStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();

    // Calculate weekly check-ins from session data
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyCheckins = List.generate(7, (i) {
      final day = weekStart.add(Duration(days: i));
      final dayKey = DateTime(day.year, day.month, day.day);
      final sessionOnDay = _sessions.where(
        (s) =>
            s.startedAt.year == dayKey.year &&
            s.startedAt.month == dayKey.month &&
            s.startedAt.day == dayKey.day,
      );
      return DailyCheckIn(
        date: dayKey,
        isCheckedIn: sessionOnDay.isNotEmpty,
        dominantEmotion: sessionOnDay.isNotEmpty
            ? sessionOnDay.first.displayEmotion
            : null,
      );
    });

    final streakDays = weeklyCheckins.where((c) => c.isCheckedIn).length;

    // Find dominant mood from recent sessions
    EmotionLabelType currentMood = EmotionLabelType.neutral;
    int currentMoodPercentage = 76;
    final sorted = List<DetectionSessionModel>.from(_sessions)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    if (sorted.isNotEmpty) {
      currentMood = sorted.first.displayEmotion;
      currentMoodPercentage = (sorted.first.displayConfidence * 100).round();
    }

    return HomeStats(
      currentMood: currentMood,
      currentMoodPercentage: currentMoodPercentage,
      moodDescription:
          'Berdasarkan analisis suara terakhir, kondisi emosionalmu stabil dan positif. Terus jaga ritme harianmu!',
      totalRecordings: _sessions.length,
      streakDays: streakDays,
      weeklyCheckins: weeklyCheckins,
    );
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _sessions.removeWhere((s) => s.id == sessionId);
  }

  @override
  Future<DetectionSessionModel> correctEmotion(
    String sessionId,
    EmotionLabelType newLabel,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx < 0) {
      throw Exception('Sesi tidak ditemukan: $sessionId');
    }
    final updated = _sessions[idx].copyWith(correctedEmotion: newLabel);
    _sessions[idx] = updated;
    return updated;
  }

  @override
  Future<DetectionSessionModel> updateNote(
    String sessionId,
    String? note,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx < 0) {
      throw Exception('Sesi tidak ditemukan: $sessionId');
    }
    final trimmed = note?.trim();
    final updated = _sessions[idx].copyWith(
      note: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
    );
    _sessions[idx] = updated;
    return updated;
  }

  @override
  Future<Map<EmotionLabelType, int>> getWeeklyChart() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final counts = <EmotionLabelType, int>{
      for (final e in EmotionLabelType.values) e: 0,
    };
    for (final s in _sessions) {
      if (s.startedAt.isAfter(cutoff)) {
        counts[s.displayEmotion] = (counts[s.displayEmotion] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Future<List<EmotionSeriesPoint>> getChartSeries({int days = 7}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final points = <EmotionSeriesPoint>[];
    for (int i = days - 1; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final next = day.add(const Duration(days: 1));
      final counts = <EmotionLabelType, int>{
        for (final e in EmotionLabelType.values) e: 0,
      };
      for (final s in _sessions) {
        if (s.startedAt.isAfter(day) && s.startedAt.isBefore(next)) {
          counts[s.displayEmotion] = (counts[s.displayEmotion] ?? 0) + 1;
        }
      }
      points.add(EmotionSeriesPoint(date: day, counts: counts));
    }
    return points;
  }

  // ── Mock Data Generator ────────────────────────────────────────────────

  List<DetectionSessionModel> _generateMockSessions() {
    final now = DateTime.now();
    final emotions = EmotionLabelType.values;

    return List.generate(10, (i) {
      final date = now.subtract(Duration(days: i * 2 + 1, hours: i));
      final emotion = emotions[i % emotions.length];
      final sessionId = 'session_${i + 1}';

      return DetectionSessionModel(
        id: sessionId,
        userId: 'usr_001',
        startedAt: date,
        stoppedAt: date.add(Duration(minutes: 2 + i, seconds: 30)),
        sourceType: i % 3 == 0
            ? DetectionSourceType.upload
            : DetectionSourceType.live,
        dominantEmotion: emotion,
        dominantConfidence: 0.65 + (i % 4) * 0.08,
        results: _generateMockResults(sessionId, emotion, date),
      );
    });
  }

  List<DetectionResultModel> _generateMockResults(
    String sessionId,
    EmotionLabelType dominant,
    DateTime baseTime,
  ) {
    final emotions = EmotionLabelType.values;
    return List.generate(5, (i) {
      final startSec = i * 3.0;
      final emotion = i == 0 || i == 3 ? dominant : emotions[(i + 1) % 6];
      return DetectionResultModel(
        id: '${sessionId}_result_$i',
        sessionId: sessionId,
        startSec: startSec,
        endSec: startSec + 3.0,
        label: emotion,
        confidence: 0.6 + (i % 3) * 0.1,
        allProbs: List.generate(6, (j) => j == emotion.index ? 0.7 : 0.06),
      );
    });
  }
}
