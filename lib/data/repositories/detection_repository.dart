import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/models/emotion_summary_model.dart';

/// Contract for detection session data operations.
/// Implementations: DummyDetectionRepository, (future) SqliteDetectionRepository, ApiDetectionRepository
abstract class DetectionRepository {
  /// Get paginated session history.
  Future<List<DetectionSessionModel>> getSessionHistory({
    int limit = 20,
    int offset = 0,
  });

  /// Get a single session by its ID.
  Future<DetectionSessionModel?> getSessionById(String id);

  /// Persist a detection session.
  Future<DetectionSessionModel> saveSession(DetectionSessionModel session);

  /// Get emotion data for calendar view.
  Future<Map<DateTime, EmotionLabelType>> getCalendarEmotions(
    int year,
    int month,
  );

  /// Get aggregated stats for the home screen.
  Future<HomeStats> getHomeStats();
}
