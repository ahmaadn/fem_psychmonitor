import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/detection_result_model.dart';

/// Represents a complete detection session (live recording or file upload).
class DetectionSessionModel {
  final String id;
  final String userId;
  final DateTime startedAt;
  final DateTime stoppedAt;
  final DetectionSourceType sourceType;
  final String? audioFilePath;
  final EmotionLabelType dominantEmotion;
  final double dominantConfidence;
  final List<DetectionResultModel> results;

  const DetectionSessionModel({
    required this.id,
    required this.userId,
    required this.startedAt,
    required this.stoppedAt,
    required this.sourceType,
    this.audioFilePath,
    required this.dominantEmotion,
    required this.dominantConfidence,
    required this.results,
  });

  Duration get duration => stoppedAt.difference(startedAt);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startedAt': startedAt.toIso8601String(),
      'stoppedAt': stoppedAt.toIso8601String(),
      'sourceType': sourceType.name,
      'audioFilePath': audioFilePath,
      'dominantEmotion': dominantEmotion.name,
      'dominantConfidence': dominantConfidence,
      'results': results.map((r) => r.toJson()).toList(),
    };
  }

  factory DetectionSessionModel.fromJson(Map<String, dynamic> json) {
    return DetectionSessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      stoppedAt: DateTime.parse(json['stoppedAt'] as String),
      sourceType: DetectionSourceType.values.firstWhere(
        (e) => e.name == json['sourceType'],
        orElse: () => DetectionSourceType.live,
      ),
      audioFilePath: json['audioFilePath'] as String?,
      dominantEmotion: EmotionLabelType.values.firstWhere(
        (e) => e.name == json['dominantEmotion'],
        orElse: () => EmotionLabelType.neutral,
      ),
      dominantConfidence: (json['dominantConfidence'] as num).toDouble(),
      results: (json['results'] as List<dynamic>?)
              ?.map((e) =>
                  DetectionResultModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

enum DetectionSourceType { live, upload }
