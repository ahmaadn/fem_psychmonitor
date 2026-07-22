import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/score_log_repository.dart';
import 'package:flutter/foundation.dart';

/// ViewModel for the History/Discover screen: calendar + sessions + charts.
class HistoryViewModel extends ChangeNotifier {
  final DetectionRepository _detectionRepo;
  final ScoreLogRepository _scoreLogRepo = ScoreLogRepository();

  List<DetectionSessionModel> _sessions = [];
  Map<DateTime, EmotionLabelType> _calendarData = {};
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
  Map<DateTime, EmotionLabelType> get calendarData => _calendarData;
  Map<DateTime, EmotionLabelType> get calendarEmotions => _calendarData;
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

  /// Load calendar emotion data for a specific month (merges into cache).
  Future<void> loadCalendarData(int year, int month) async {
    _currentYear = year;
    _currentMonth = month;

    try {
      final chunk = await _detectionRepo.getCalendarEmotions(year, month);
      // Drop keys for this month then merge (supports infinite multi-month cache).
      _calendarData.removeWhere(
        (d, _) => d.year == year && d.month == month,
      );
      _calendarData.addAll(chunk);
    } catch (e) {
      _error = 'Gagal memuat data kalender: $e';
    }
    notifyListeners();
  }

  Future<void> loadCalendar(int year, int month) =>
      loadCalendarData(year, month);

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

  /// Get the dominant emotion label for the current month.
  EmotionLabelType? get monthlyDominantEmotion {
    if (_calendarData.isEmpty) return null;
    final counts = <EmotionLabelType, int>{};
    for (final emotion in _calendarData.values) {
      counts[emotion] = (counts[emotion] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
