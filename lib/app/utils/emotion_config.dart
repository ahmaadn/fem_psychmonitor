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

  /// Path to the raster emoji asset shipped under `assets/emoji/`.
  String get emojiAsset {
    const paths = [
      'assets/emoji/bahagia.png', // happy
      'assets/emoji/sedih.png', // sad
      'assets/emoji/marah.png', // anger
      'assets/emoji/takut.png', // fearful
      'assets/emoji/jijik.png', // disgust
      'assets/emoji/netral.png', // neutral
    ];
    return paths[index];
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

  /// Theme-invariant base fill / chart / icon color (DESIGN.md §2.6).
  Color get color {
    switch (this) {
      case EmotionLabelType.happy:
        return AppColors.emotionHappy;
      case EmotionLabelType.sad:
        return AppColors.emotionSad;
      case EmotionLabelType.anger:
        return AppColors.emotionAnger;
      case EmotionLabelType.fearful:
        return AppColors.emotionFearful;
      case EmotionLabelType.disgust:
        return AppColors.emotionDisgust;
      case EmotionLabelType.neutral:
        return AppColors.emotionNeutral;
    }
  }

  /// Soft chip fill (~15% opacity of base).
  Color get surfaceColor => color.withValues(alpha: 0.15);

  /// Prefer [onColorFor] with theme brightness when possible.
  Color get onColor => onColorFor(Brightness.light);

  Color onColorFor(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    switch (this) {
      case EmotionLabelType.happy:
        return dark
            ? AppColors.emotionHappyOnDark
            : AppColors.emotionHappyOnLight;
      case EmotionLabelType.sad:
        return dark
            ? AppColors.emotionSadOnDark
            : AppColors.emotionSadOnLight;
      case EmotionLabelType.anger:
        return dark
            ? AppColors.emotionAngerOnDark
            : AppColors.emotionAngerOnLight;
      case EmotionLabelType.fearful:
        return dark
            ? AppColors.emotionFearfulOnDark
            : AppColors.emotionFearfulOnLight;
      case EmotionLabelType.disgust:
        return dark
            ? AppColors.emotionDisgustOnDark
            : AppColors.emotionDisgustOnLight;
      case EmotionLabelType.neutral:
        return dark
            ? AppColors.emotionNeutralOnDark
            : AppColors.emotionNeutralOnLight;
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
