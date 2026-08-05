import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/calendar_day_summary.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/score_log_repository.dart';
import 'package:flutter/foundation.dart';

/// ViewModel for the History/Discover screen: calendar + sessions + charts.
class HistoryViewModel extends ChangeNotifier {
  final DetectionRepository _detectionRepo;
  final ScoreLogRepository _scoreLogRepo = ScoreLogRepository();

  List<DetectionSessionModel> _sessions = [];
  final Map<DateTime, CalendarDaySummary> _calendarSummaries = {};
  List<EmotionSeriesPoint> _chartSeries = [];
  List<ScoreSeriesPoint> _scoreSeries = [];
  bool _isLoading = false;
  String? _error;
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;
  DateTime _selectedDate = _dateOnly(DateTime.now());
  String? _userId;

  /// US-11: null = all time, 7 = last 7 days.
  int? _filterDays;

  HistoryViewModel({required DetectionRepository detectionRepo})
    : _detectionRepo = detectionRepo;

  // ── Getters ────────────────────────────────────────────────────────────

  List<DetectionSessionModel> get sessions => _sessions;

  /// Per-day emotion summaries keyed by local midnight.
  Map<DateTime, CalendarDaySummary> get calendarSummaries =>
      _calendarSummaries;

  /// Convenience: dominant emotion per day, derived from [calendarSummaries].
  Map<DateTime, EmotionLabelType> get calendarEmotions => {
    for (final e in _calendarSummaries.entries) e.key: e.value.dominant,
  };

  List<EmotionSeriesPoint> get chartSeries => _chartSeries;
  List<ScoreSeriesPoint> get scoreSeries => _scoreSeries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setUserId(String? userId) {
    _userId = userId;
  }
  int? get filterDays => _filterDays;
  bool get isFilteredTo7Days => _filterDays == 7;
  DateTime get selectedDate => _selectedDate;

  // ── Actions ────────────────────────────────────────────────────────────

  /// US-11: toggle the 7-day filter and reload sessions + chart.
  Future<void> toggle7DayFilter() async {
    _filterDays = isFilteredTo7Days ? null : 7;
    notifyListeners();
    await loadSessions();
    await loadChartSeries();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = _dateOnly(date);
    notifyListeners();
    await loadSessions();
  }

  /// Load sessions for the selected calendar date.
  Future<void> loadSessions({int limit = 20, int offset = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _detectionRepo.getSessionHistory(
        limit: limit,
        offset: offset,
        startedOnDate: _selectedDate,
      );
    } catch (e) {
      _error = 'Gagal memuat riwayat: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load per-day emotion summaries for a specific month (merges into cache).
  Future<void> loadCalendarData(int year, int month) async {
    _currentYear = year;
    _currentMonth = month;

    try {
      final chunk = await _detectionRepo.getCalendarSummaries(
        year: year,
        month: month,
      );
      // Drop keys for this month then merge (supports infinite multi-month cache).
      _calendarSummaries.removeWhere(
        (d, _) => d.year == year && d.month == month,
      );
      _calendarSummaries.addAll(chunk);
    } catch (e) {
      _error = 'Gagal memuat data kalender: $e';
    }
    notifyListeners();
  }

  Future<void> loadCalendar(int year, int month) =>
      loadCalendarData(year, month);

  /// Load all 12 months of [year] and notify **once**.
  ///
  /// The Discover calendar renders a whole year at a time; calling
  /// [loadCalendarData] per month would emit 12 separate notifications and
  /// rebuild the year list 12 times.
  Future<void> loadCalendarYear(int year) async {
    try {
      final results = await Future.wait([
        for (var month = 1; month <= 12; month++)
          _detectionRepo.getCalendarSummaries(year: year, month: month),
      ]);
      _calendarSummaries.removeWhere((d, _) => d.year == year);
      for (final chunk in results) {
        _calendarSummaries.addAll(chunk);
      }
      _currentYear = year;
    } catch (e) {
      _error = 'Gagal memuat data kalender: $e';
    }
    notifyListeners();
  }

  Future<void> loadHistory() => loadAll();

  Future<List<DetectionSessionModel>> loadSessionsForDate(DateTime day) async {
    try {
      return await _detectionRepo.getSessionHistory(
        limit: 100,
        startedOnDate: DateTime(day.year, day.month, day.day),
      );
    } catch (e) {
      _error = 'Gagal memuat sesi: $e';
      notifyListeners();
      return [];
    }
  }

  /// US-19: load the time-series chart data.
  Future<void> loadChartSeries({int days = 7}) async {
    try {
      _chartSeries = await _detectionRepo.getChartSeries(days: days);
      if (_userId != null) {
        _scoreSeries = await _scoreLogRepo.getDailySeries(
          userId: _userId!,
          days: days,
        );
      } else {
        _scoreSeries = [];
      }
    } catch (e) {
      _error = 'Gagal memuat data chart: $e';
    }
    notifyListeners();
  }

  /// Convenience: load sessions, calendar and chart for current month.
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      loadSessions(),
      loadCalendarData(_currentYear, _currentMonth),
      loadChartSeries(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  /// Progress for the calendar cache: years/months that have been loaded.
  bool isSummaryLoaded(DateTime date) =>
      _calendarSummaries.containsKey(_dateOnly(date));

  /// Total recordings on the given day, or 0 if none.
  int totalSessionsOn(DateTime date) {
    final s = _calendarSummaries[_dateOnly(date)];
    return s?.total ?? 0;
  }

  /// Get the dominant emotion label for the current month.
  EmotionLabelType? get monthlyDominantEmotion {
    if (_calendarSummaries.isEmpty) return null;
    final counts = <EmotionLabelType, int>{};
    for (final summary in _calendarSummaries.values) {
      counts[summary.dominant] = (counts[summary.dominant] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
