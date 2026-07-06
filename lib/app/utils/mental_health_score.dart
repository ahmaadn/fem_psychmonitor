import 'dart:math' as math;

import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';

int applyDetectionMentalHealthImpact({
  required int currentScore,
  required DetectionSessionModel session,
  DetectionSessionModel? previousSession,
}) {
  final previousDelta = previousSession == null
      ? 0
      : detectionMentalHealthDelta(previousSession);
  final delta = detectionMentalHealthDelta(session) - previousDelta;
  return (currentScore + delta).clamp(0, 100).toInt();
}

int detectionMentalHealthDelta(DetectionSessionModel session) {
  return mentalHealthScoreBreakdown(session).delta;
}

MentalHealthScoreBreakdown mentalHealthScoreBreakdown(
  DetectionSessionModel session,
) {
  final emotion = session.displayEmotion;
  final confidence = session.displayConfidence.clamp(0.0, 1.0);
  final effectiveConfidence = session.correctedEmotion == null
      ? confidence
      : math.max(0.65, confidence);
  final impactWeight = emotionMentalHealthImpact(emotion);
  final weighted = impactWeight * effectiveConfidence;
  final rounded = weighted.round();

  final delta = rounded != 0 || effectiveConfidence == 0
      ? rounded
      : weighted.isNegative
      ? -1
      : 1;

  return MentalHealthScoreBreakdown(
    emotion: emotion,
    modelConfidence: confidence,
    effectiveConfidence: effectiveConfidence,
    impactWeight: impactWeight,
    weightedImpact: weighted,
    delta: delta,
    isCorrected: session.correctedEmotion != null,
  );
}

double emotionMentalHealthImpact(EmotionLabelType emotion) {
  switch (emotion) {
    case EmotionLabelType.happy:
      return 3;
    case EmotionLabelType.neutral:
      return 1;
    case EmotionLabelType.sad:
      return -4;
    case EmotionLabelType.anger:
      return -4;
    case EmotionLabelType.fearful:
      return -5;
    case EmotionLabelType.disgust:
      return -3;
  }
}

class MentalHealthScoreBreakdown {
  const MentalHealthScoreBreakdown({
    required this.emotion,
    required this.modelConfidence,
    required this.effectiveConfidence,
    required this.impactWeight,
    required this.weightedImpact,
    required this.delta,
    required this.isCorrected,
  });

  final EmotionLabelType emotion;
  final double modelConfidence;
  final double effectiveConfidence;
  final double impactWeight;
  final double weightedImpact;
  final int delta;
  final bool isCorrected;
}
