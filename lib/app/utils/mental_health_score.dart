import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';

/// PLAN §9 base emotion scores.
double emotionBaseScore(EmotionLabelType emotion) {
  switch (emotion) {
    case EmotionLabelType.happy:
      return 8;
    case EmotionLabelType.neutral:
      return 2;
    case EmotionLabelType.sad:
      return -6;
    case EmotionLabelType.anger:
      return -7;
    case EmotionLabelType.fearful:
      return -8;
    case EmotionLabelType.disgust:
      return -5;
  }
}

int applyDetectionMentalHealthImpact({
  required int currentScore,
  required DetectionSessionModel session,
  DetectionSessionModel? previousSession,
}) {
  final previousDelta = previousSession == null
      ? 0.0
      : detectionMentalHealthDelta(previousSession);
  final delta = detectionMentalHealthDelta(session) - previousDelta;
  return (currentScore + delta.round()).clamp(0, 100).toInt();
}

double detectionMentalHealthDelta(DetectionSessionModel session) {
  return mentalHealthScoreBreakdown(session).delta;
}

MentalHealthScoreBreakdown mentalHealthScoreBreakdown(
  DetectionSessionModel session,
) {
  final emotion = session.displayEmotion;
  final confidence = session.displayConfidence.clamp(0.0, 1.0);
  final base = emotionBaseScore(emotion);
  final isCorrected = session.correctedEmotion != null;
  // PLAN: uncorrected = base * confidence; corrected = 0.6 * base
  final delta = isCorrected ? 0.6 * base : base * confidence;

  return MentalHealthScoreBreakdown(
    emotion: emotion,
    modelConfidence: confidence,
    effectiveConfidence: isCorrected ? 0.6 : confidence,
    impactWeight: base,
    weightedImpact: delta,
    delta: delta,
    isCorrected: isCorrected,
  );
}

/// Legacy name used by some call sites expecting int impact weight.
double emotionMentalHealthImpact(EmotionLabelType emotion) =>
    emotionBaseScore(emotion);

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
  final double delta;
  final bool isCorrected;
}

/// Psych score class keys (stable, not localized).
String psychClassKeyForScore(int score) {
  if (score <= 25) return 'butuh_perhatian';
  if (score <= 50) return 'rentan';
  if (score <= 75) return 'cukup_sehat';
  return 'sehat';
}

bool isSafetyScore(int? score) => score != null && score <= 25;
