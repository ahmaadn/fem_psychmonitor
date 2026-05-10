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

  /// Clear the current session reference.
  void clearCurrentSession() {
    _currentSession = null;
    notifyListeners();
  }
}
