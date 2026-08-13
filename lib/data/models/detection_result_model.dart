import 'package:fem_psychmonitor/app/utils/emotion_config.dart';

/// A single detection result within a session.
/// Maps 1:1 with [EmotionResult] but adds persistence fields.
class DetectionResultModel {
  final String id;
  final String sessionId;
  final double startSec;
  final double endSec;
  final EmotionLabelType label;
  final double confidence;
  final List<double> allProbs;

  const DetectionResultModel({
    required this.id,
    required this.sessionId,
    required this.startSec,
    required this.endSec,
    required this.label,
    required this.confidence,
    required this.allProbs,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'startSec': startSec,
      'endSec': endSec,
      'label': label.name,
      'confidence': confidence,
      'allProbs': allProbs,
    };
  }

  factory DetectionResultModel.fromJson(Map<String, dynamic> json) {
    return DetectionResultModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      startSec: (json['startSec'] as num).toDouble(),
      endSec: (json['endSec'] as num).toDouble(),
      label: EmotionLabelType.values.firstWhere(
        (e) => e.name == json['label'],
        orElse: () => EmotionLabelType.neutral,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      allProbs: (json['allProbs'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  /// Convert from the existing [EmotionResult] used in real-time detection.
  factory DetectionResultModel.fromEmotionResult(
    EmotionResult result, {
    required String id,
    required String sessionId,
  }) {
    return DetectionResultModel(
      id: id,
      sessionId: sessionId,
      startSec: result.startSec,
      endSec: result.endSec,
      label: result.label,
      confidence: result.confidence,
      allProbs: result.allProbs,
    );
  }

  /// Convert back to [EmotionResult] for timeline widgets.
  EmotionResult toEmotionResult() {
    return EmotionResult(
      startSec: startSec,
      endSec: endSec,
      label: label,
      confidence: confidence,
      allProbs: allProbs,
      requestId: 0,
    );
  }
}
