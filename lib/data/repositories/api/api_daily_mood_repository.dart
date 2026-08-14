import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_client.dart';

class RemoteDailyMood {
  const RemoteDailyMood({
    required this.userId,
    required this.date,
    required this.emotion,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String date;
  final EmotionLabelType emotion;
  final int createdAt;
  final int updatedAt;

  factory RemoteDailyMood.fromJson(Map<String, dynamic> json) {
    return RemoteDailyMood(
      userId: json['userId'] as String,
      date: json['date'] as String,
      emotion: EmotionLabelType.values.firstWhere(
        (value) => value.name == json['emotion'],
        orElse: () => EmotionLabelType.neutral,
      ),
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
    );
  }
}

class ApiDailyMoodRepository {
  ApiDailyMoodRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<RemoteDailyMood> upsert({
    required String date,
    required EmotionLabelType emotion,
  }) async {
    final json = await _api.requestJson(
      'PUT',
      '/daily-moods/$date',
      body: {'emotion': emotion.name},
    );
    return RemoteDailyMood.fromJson(json['mood'] as Map<String, dynamic>);
  }
}
