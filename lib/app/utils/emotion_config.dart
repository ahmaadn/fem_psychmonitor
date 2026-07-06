import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:flutter/material.dart';

enum EmotionLabelType { happy, sad, anger, fearful, disgust, neutral }

extension EmotionLabelTypeExtension on EmotionLabelType {
  String get emoji {
    const emojis = [
      '😄', // happy
      '😢', // sad
      '😠', // anger
      '😨', // fearful
      '🤢', // disgust
      '😐', // neutral
    ];
    return emojis[index];
  }

  String get label {
    switch (this) {
      case EmotionLabelType.happy:
        return 'Happy';
      case EmotionLabelType.sad:
        return 'Sad';
      case EmotionLabelType.anger:
        return 'Anger';
      case EmotionLabelType.fearful:
        return 'Fearful';
      case EmotionLabelType.disgust:
        return 'Disgust';
      case EmotionLabelType.neutral:
        return 'Neutral';
    }
  }

  String get displayName {
    switch (this) {
      case EmotionLabelType.happy:
        return 'Senang';
      case EmotionLabelType.sad:
        return 'Sedih';
      case EmotionLabelType.anger:
        return 'Marah';
      case EmotionLabelType.fearful:
        return 'Takut';
      case EmotionLabelType.disgust:
        return 'Jijik';
      case EmotionLabelType.neutral:
        return 'Netral';
    }
  }

  Color get color {
    switch (this) {
      case EmotionLabelType.happy:
        return AppColors.emotionHappiness;
      case EmotionLabelType.sad:
        return AppColors.emotionSadness;
      case EmotionLabelType.anger:
        return AppColors.emotionAnger;
      case EmotionLabelType.fearful:
        return AppColors.emotionFear;
      case EmotionLabelType.disgust:
        return AppColors.emotionDisgust;
      case EmotionLabelType.neutral:
        return AppColors.emotionNetral;
    }
  }

  Color get surfaceColor {
    switch (this) {
      case EmotionLabelType.happy:
        return AppColors.emotionHappinessSurface;
      case EmotionLabelType.sad:
        return AppColors.emotionSadnessSurface;
      case EmotionLabelType.anger:
        return AppColors.emotionAngerSurface;
      case EmotionLabelType.fearful:
        return AppColors.emotionFearSurface;
      case EmotionLabelType.disgust:
        return AppColors.emotionDisgustSurface;
      case EmotionLabelType.neutral:
        return AppColors.emotionNetralSurface;
    }
  }

  Color get onColor {
    switch (this) {
      case EmotionLabelType.anger:
        return AppColors.onEmotionAnger;
      case EmotionLabelType.sad:
        return AppColors.onEmotionSadness;
      case EmotionLabelType.happy:
        return AppColors.onEmotionHappiness;
      case EmotionLabelType.disgust:
        return AppColors.onEmotionDisgust;
      case EmotionLabelType.fearful:
        return AppColors.onEmotionFear;
      case EmotionLabelType.neutral:
        return AppColors.onEmotionNetral;
    }
  }
}

class EmotionResult {
  final double startSec;
  final double endSec;
  final EmotionLabelType label;
  final double confidence;
  final List<double> allProbs; // softmax probs for all 6 classes
  final int requestId;

  const EmotionResult({
    required this.startSec,
    required this.endSec,
    required this.label,
    required this.confidence,
    required this.allProbs,
    required this.requestId,
  });

  @override
  String toString() =>
      '[${startSec.toStringAsFixed(1)}-${endSec.toStringAsFixed(1)}s] '
      '${label.displayName} (${(confidence * 100).toStringAsFixed(1)}%)';
}

/// Dominant emotion = most frequent label (mode); confidence = average of
/// that label's per-chunk confidences. Tie-break: higher avg confidence,
/// then enum index. Empty -> (neutral, 0.0).
({EmotionLabelType emotion, double confidence}) dominantFromResults(
  Iterable<EmotionResult> results,
) {
  final count = <EmotionLabelType, int>{};
  final sumConfidence = <EmotionLabelType, double>{};

  for (final r in results) {
    count[r.label] = (count[r.label] ?? 0) + 1;
    sumConfidence[r.label] = (sumConfidence[r.label] ?? 0.0) + r.confidence;
  }

  if (count.isEmpty) {
    return (emotion: EmotionLabelType.neutral, confidence: 0.0);
  }

  EmotionLabelType best = EmotionLabelType.neutral;
  int bestCount = -1;
  double bestAvg = -1.0;

  for (final label in EmotionLabelType.values) {
    final c = count[label];
    if (c == null) continue;
    final avg = sumConfidence[label]! / c;

    final isBetter = c > bestCount ||
        (c == bestCount && avg > bestAvg) ||
        (c == bestCount && avg == bestAvg && label.index > best.index);

    if (isBetter) {
      best = label;
      bestCount = c;
      bestAvg = avg;
    }
  }

  return (emotion: best, confidence: bestAvg);
}
