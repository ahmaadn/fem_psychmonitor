import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:flutter/foundation.dart';

/// ViewModel for saving and retrieving detection sessions.
/// Works alongside the existing EmotionDetector which handles real-time inference.
class DetectionViewModel extends ChangeNotifier {
  final DetectionRepository _detectionRepo;

  DetectionSessionModel? _currentSession;
  DetectionSessionModel? _viewedSession;
  bool _isSaving = false;
  String? _error;

  DetectionViewModel({required DetectionRepository detectionRepo})
      : _detectionRepo = detectionRepo;

  // ── Getters ────────────────────────────────────────────────────────────

  DetectionSessionModel? get currentSession => _currentSession;
  DetectionSessionModel? get viewedSession => _viewedSession;
  bool get isSaving => _isSaving;
  String? get error => _error;

  // ── Actions ────────────────────────────────────────────────────────────

  /// Save a completed detection session to the repository.
  Future<void> saveCurrentSession(DetectionSessionModel session) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      _currentSession = await _detectionRepo.saveSession(session);
    } catch (e) {
      _error = 'Gagal menyimpan sesi: $e';
    }

    _isSaving = false;
    notifyListeners();
  }

  /// Load a specific session by ID for viewing.
  Future<DetectionSessionModel?> getSession(String id) async {
    try {
      _viewedSession = await _detectionRepo.getSessionById(id);
      notifyListeners();
      return _viewedSession;
    } catch (e) {
      _error = 'Gagal memuat sesi: $e';
      notifyListeners();
      return null;
    }
  }

  /// US-17: correct a session's dominant emotion label.
  Future<void> correctSession(
    String sessionId,
    EmotionLabelType newLabel,
  ) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _detectionRepo.correctEmotion(sessionId, newLabel);
      if (_currentSession?.id == sessionId) {
        _currentSession = updated;
      }
      if (_viewedSession?.id == sessionId) {
        _viewedSession = updated;
      }
    } catch (e) {
      _error = 'Gagal mengoreksi emosi: $e';
    }

    _isSaving = false;
    notifyListeners();
  }

  /// US-18: weekly emotion distribution for the hotline/chart card.
  Future<Map<EmotionLabelType, int>> loadWeeklyChart() async {
    try {
      return await _detectionRepo.getWeeklyChart();
    } catch (e) {
      _error = 'Gagal memuat chart mingguan: $e';
      notifyListeners();
      return {};
    }
  }

  /// US-09: persist a free-text note attached to a session. Keeps the
  /// current/viewed session references in sync so the UI reflects the new
  /// note immediately without a full reload.
  Future<void> updateNote(String sessionId, String? note) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _detectionRepo.updateNote(sessionId, note);
      if (_currentSession?.id == sessionId) {
        _currentSession = updated;
      }
      if (_viewedSession?.id == sessionId) {
        _viewedSession = updated;
      }
    } catch (e) {
      _error = 'Gagal menyimpan catatan: $e';
    }

    _isSaving = false;
    notifyListeners();
  }

  /// Clear the current session reference.
  void clearCurrentSession() {
    _currentSession = null;
    notifyListeners();
  }
}
