import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/models/emotion_summary_model.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:http/http.dart' as http;

/// HTTP-backed [DetectionRepository] scaffold. No-op until a [baseUrl] is set.
class ApiDetectionRepository extends DetectionRepository {
  ApiDetectionRepository({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl,
        _client = client ?? http.Client();

  final String? baseUrl;
  final http.Client _client;

  bool get _isEnabled => baseUrl != null && baseUrl!.isNotEmpty;

  @override
  Future<List<DetectionSessionModel>> getSessionHistory({
    int limit = 20,
    int offset = 0,
    int? filterDays,
  }) async {
    if (!_isEnabled) return [];
    // TODO(server): GET {baseUrl}/sessions?limit=&offset=&days=
    throw UnimplementedError('ApiDetectionRepository requires a live server');
  }

  @override
  Future<DetectionSessionModel?> getSessionById(String id) async {
    if (!_isEnabled) return null;
    throw UnimplementedError('ApiDetectionRepository requires a live server');
  }

  @override
  Future<DetectionSessionModel> saveSession(
    DetectionSessionModel session,
  ) async {
    if (!_isEnabled) return session;
    // TODO(server): POST {baseUrl}/sessions with session.toJson()
    throw UnimplementedError('ApiDetectionRepository requires a live server');
  }

  @override
  Future<Map<DateTime, EmotionLabelType>> getCalendarEmotions(
    int year,
    int month,
  ) async {
    if (!_isEnabled) return {};
    throw UnimplementedError('ApiDetectionRepository requires a live server');
  }

  @override
  Future<HomeStats> getHomeStats() async {
    if (!_isEnabled) {
      throw StateError('ApiDetectionRepository disabled — no base URL configured');
    }
    throw UnimplementedError('ApiDetectionRepository requires a live server');
  }

  @override
  Future<DetectionSessionModel> correctEmotion(
    String sessionId,
    EmotionLabelType newLabel,
  ) async {
    if (!_isEnabled) {
      throw StateError('ApiDetectionRepository disabled — no base URL configured');
    }
    // TODO(server): PATCH {baseUrl}/sessions/{id} {corrected_emotion}
    throw UnimplementedError('ApiDetectionRepository requires a live server');
  }

  @override
  Future<Map<EmotionLabelType, int>> getWeeklyChart() async {
    if (!_isEnabled) return {};
    throw UnimplementedError('ApiDetectionRepository requires a live server');
  }

  @override
  Future<List<EmotionSeriesPoint>> getChartSeries({int days = 7}) async {
    if (!_isEnabled) return [];
    throw UnimplementedError('ApiDetectionRepository requires a live server');
  }

  void close() => _client.close();
}
