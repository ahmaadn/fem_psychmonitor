import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:flutter/foundation.dart';

/// ViewModel for the History screen: calendar data + session list + chart series.
class HistoryViewModel extends ChangeNotifier {
  final DetectionRepository _detectionRepo;

  List<DetectionSessionModel> _sessions = [];
  Map<DateTime, EmotionLabelType> _calendarData = {};
  List<EmotionSeriesPoint> _chartSeries = [];
  bool _isLoading = false;
  String? _error;
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;

  /// US-11: null = all time, 7 = last 7 days.
  int? _filterDays;

  HistoryViewModel({required DetectionRepository detectionRepo})
      : _detectionRepo = detectionRepo;

  // ── Getters ────────────────────────────────────────────────────────────

  List<DetectionSessionModel> get sessions => _sessions;
  Map<DateTime, EmotionLabelType> get calendarData => _calendarData;
  List<EmotionSeriesPoint> get chartSeries => _chartSeries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get filterDays => _filterDays;
  bool get isFilteredTo7Days => _filterDays == 7;

  // ── Actions ────────────────────────────────────────────────────────────

  /// US-11: toggle the 7-day filter and reload sessions + chart.
  Future<void> toggle7DayFilter() async {
    _filterDays = isFilteredTo7Days ? null : 7;
    notifyListeners();
    await loadSessions();
    await loadChartSeries();
  }

  /// Load recent sessions for the list, honouring the active [filterDays].
  Future<void> loadSessions({int limit = 20, int offset = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _detectionRepo.getSessionHistory(
        limit: limit,
        offset: offset,
        filterDays: _filterDays,
      );
    } catch (e) {
      _error = 'Gagal memuat riwayat: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load calendar emotion data for a specific month.
  Future<void> loadCalendarData(int year, int month) async {
    _currentYear = year;
    _currentMonth = month;

    try {
      _calendarData = await _detectionRepo.getCalendarEmotions(year, month);
    } catch (e) {
      _error = 'Gagal memuat data kalender: $e';
    }
    notifyListeners();
  }

  /// US-19: load the time-series chart data.
  Future<void> loadChartSeries({int days = 7}) async {
    try {
      _chartSeries = await _detectionRepo.getChartSeries(days: days);
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
}
