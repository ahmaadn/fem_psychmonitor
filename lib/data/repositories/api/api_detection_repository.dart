import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/models/emotion_summary_model.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_daily_mood_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_client.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:intl/intl.dart';

class RemoteSyncSnapshot {
  const RemoteSyncSnapshot({
    required this.serverTime,
    required this.users,
    required this.sessions,
    required this.dailyMoods,
  });

  final int serverTime;
  final List<Map<String, dynamic>> users;
  final List<DetectionSessionModel> sessions;
  final List<RemoteDailyMood> dailyMoods;
}

class ApiDetectionRepository extends DetectionRepository {
  ApiDetectionRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  bool get isEnabled => _api.isEnabled;
  bool get hasRemoteSession => _api.hasRemoteSession;

  @override
  Future<List<DetectionSessionModel>> getSessionHistory({
    int limit = 20,
    int offset = 0,
    int? filterDays,
    DateTime? startedOnDate,
  }) async {
    final query = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
      if (filterDays != null) 'days': '$filterDays',
      if (startedOnDate != null)
        'on': DateFormat('yyyy-MM-dd').format(startedOnDate),
    };
    final uri = Uri(path: '/sessions', queryParameters: query);
    final json = await _api.requestJson('GET', uri.toString());
    return (json['items'] as List<dynamic>)
        .map((item) => sessionFromServer(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DetectionSessionModel?> getSessionById(String id) async {
    try {
      final json = await _api.requestJson('GET', '/sessions/$id');
      return sessionFromServer(json['session'] as Map<String, dynamic>);
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<DetectionSessionModel> saveSession(
    DetectionSessionModel session,
  ) async {
    final json = await _api.requestJson(
      'PUT',
      '/sessions/${session.id}',
      body: sessionToServer(session),
    );
    return sessionFromServer(json['session'] as Map<String, dynamic>);
  }

  @override
  Future<Map<DateTime, EmotionLabelType>> getCalendarEmotions(
    int year,
    int month,
  ) async {
    final json = await _api.requestJson(
      'GET',
      '/sessions/calendar?year=$year&month=$month',
    );
    final days = json['days'] as Map<String, dynamic>;
    return {
      for (final entry in days.entries)
        DateTime.parse(entry.key): _emotion(entry.value as String),
    };
  }

  @override
  Future<HomeStats> getHomeStats() async {
    final json = await _api.requestJson('GET', '/stats/home');
    final stats = json['stats'] as Map<String, dynamic>;
    return HomeStats(
      currentMood: _emotion(stats['currentMood'] as String? ?? 'neutral'),
      currentMoodPercentage: (stats['currentMoodPercentage'] as num).round(),
      moodDescription: stats['moodDescription'] as String? ?? '',
      totalRecordings: stats['totalRecordings'] as int,
      streakDays: stats['streakDays'] as int,
      weeklyCheckins: (stats['weeklyCheckins'] as List<dynamic>).map((raw) {
        final item = raw as Map<String, dynamic>;
        return DailyCheckIn(
          date: DateTime.fromMillisecondsSinceEpoch(item['date'] as int),
          isCheckedIn: item['isCheckedIn'] as bool,
          dominantEmotion: item['dominantEmotion'] == null
              ? null
              : _emotion(item['dominantEmotion'] as String),
        );
      }).toList(),
      hasDetection: stats['hasDetection'] as bool? ?? false,
    );
  }

  @override
  Future<DetectionSessionModel> correctEmotion(
    String sessionId,
    EmotionLabelType newLabel,
  ) async {
    final json = await _api.requestJson(
      'PATCH',
      '/sessions/$sessionId',
      body: {'correctedEmotion': newLabel.name},
    );
    return sessionFromServer(json['session'] as Map<String, dynamic>);
  }

  @override
  Future<DetectionSessionModel> updateNote(
    String sessionId,
    String? note,
  ) async {
    final json = await _api.requestJson(
      'PATCH',
      '/sessions/$sessionId',
      body: {'note': note},
    );
    return sessionFromServer(json['session'] as Map<String, dynamic>);
  }

  @override
  Future<Map<EmotionLabelType, int>> getWeeklyChart() async {
    final json = await _api.requestJson('GET', '/stats/weekly');
    final counts = json['counts'] as Map<String, dynamic>;
    return {
      for (final emotion in EmotionLabelType.values)
        emotion: (counts[emotion.name] as num? ?? 0).round(),
    };
  }

  @override
  Future<List<EmotionSeriesPoint>> getChartSeries({int days = 7}) async {
    final json = await _api.requestJson('GET', '/stats/series?days=$days');
    return (json['points'] as List<dynamic>).map((raw) {
      final item = raw as Map<String, dynamic>;
      final counts = item['counts'] as Map<String, dynamic>;
      return EmotionSeriesPoint(
        date: DateTime.fromMillisecondsSinceEpoch(item['date'] as int),
        counts: {
          for (final emotion in EmotionLabelType.values)
            emotion: (counts[emotion.name] as num? ?? 0).round(),
        },
      );
    }).toList();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _api.request('DELETE', '/sessions/$sessionId');
  }

  Future<RemoteSyncSnapshot> pullSince(int since) async {
    final json = await _api.requestJson('GET', '/sync?since=$since');
    return RemoteSyncSnapshot(
      serverTime: json['serverTime'] as int,
      users: (json['users'] as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList(),
      sessions: (json['sessions'] as List<dynamic>)
          .map((item) => sessionFromServer(item as Map<String, dynamic>))
          .toList(),
      dailyMoods: (json['dailyMoods'] as List<dynamic>? ?? const [])
          .map((item) => RemoteDailyMood.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

Map<String, dynamic> sessionToServer(DetectionSessionModel session) {
  return {
    'id': session.id,
    'userId': session.userId,
    'startedAt': session.startedAt.millisecondsSinceEpoch,
    'stoppedAt': session.stoppedAt.millisecondsSinceEpoch,
    'sourceType': session.sourceType.name,
    'audioFilePath': null,
    'dominantEmotion': session.dominantEmotion.name,
    'dominantConfidence': session.dominantConfidence,
    'results': session.results.map((result) => result.toJson()).toList(),
    'note': session.note,
    'correctedEmotion': session.correctedEmotion?.name,
    'selfReportEmotion': session.selfReportEmotion?.name,
  };
}

DetectionSessionModel sessionFromServer(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  for (final key in ['startedAt', 'stoppedAt']) {
    final value = normalized[key];
    if (value is num) {
      normalized[key] = DateTime.fromMillisecondsSinceEpoch(
        value.toInt(),
      ).toIso8601String();
    }
  }
  return DetectionSessionModel.fromJson(normalized);
}

EmotionLabelType _emotion(String value) {
  return EmotionLabelType.values.firstWhere(
    (emotion) => emotion.name == value,
    orElse: () => EmotionLabelType.neutral,
  );
}
