import 'package:fem_psychmonitor/data/models/emotion_summary_model.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:flutter/foundation.dart';

/// ViewModel for the Home screen stats and daily tracker.
class HomeViewModel extends ChangeNotifier {
  final DetectionRepository _detectionRepo;

  HomeStats? _stats;
  bool _isLoading = false;
  String? _error;

  HomeViewModel({required DetectionRepository detectionRepo})
      : _detectionRepo = detectionRepo;

  // ── Getters ────────────────────────────────────────────────────────────

  HomeStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Actions ────────────────────────────────────────────────────────────

  /// Load home screen statistics from repository.
  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _detectionRepo.getHomeStats();
    } catch (e) {
      _error = 'Gagal memuat statistik: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Force refresh stats.
  Future<void> refreshStats() async {
    await loadStats();
  }
}
