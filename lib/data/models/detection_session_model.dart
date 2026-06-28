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

  /// Optional free-text note attached to the session (US-09).
  final String? note;

  /// Optional user-corrected emotion label (US-17). When non-null, the UI and
  /// history list should display this value instead of [dominantEmotion].
  final EmotionLabelType? correctedEmotion;

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
    this.note,
    this.correctedEmotion,
  });

  Duration get duration => stoppedAt.difference(startedAt);

  /// The emotion label that should be presented to the user: the corrected
  /// value when present, otherwise the model's dominant prediction.
  EmotionLabelType get displayEmotion => correctedEmotion ?? dominantEmotion;

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
      'note': note,
      'correctedEmotion': correctedEmotion?.name,
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
      note: json['note'] as String?,
      correctedEmotion: json['correctedEmotion'] == null
          ? null
          : EmotionLabelType.values.firstWhere(
              (e) => e.name == json['correctedEmotion'],
              orElse: () => EmotionLabelType.neutral,
            ),
    );
  }

  DetectionSessionModel copyWith({
    String? id,
    String? userId,
    DateTime? startedAt,
    DateTime? stoppedAt,
    DetectionSourceType? sourceType,
    String? audioFilePath,
    EmotionLabelType? dominantEmotion,
    double? dominantConfidence,
    List<DetectionResultModel>? results,
    String? note,
    EmotionLabelType? correctedEmotion,
  }) {
    return DetectionSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      stoppedAt: stoppedAt ?? this.stoppedAt,
      sourceType: sourceType ?? this.sourceType,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      dominantEmotion: dominantEmotion ?? this.dominantEmotion,
      dominantConfidence: dominantConfidence ?? this.dominantConfidence,
      results: results ?? this.results,
      note: note ?? this.note,
      correctedEmotion: correctedEmotion ?? this.correctedEmotion,
    );
  }
}

enum DetectionSourceType { live, upload }
