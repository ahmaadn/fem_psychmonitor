import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:flutter/material.dart';

enum EmotionEnumType { anger, sadness, happiness, disgust, fear, netral }

extension EmotionEnumTypeExtension on EmotionEnumType {
  String get label {
    switch (this) {
      case EmotionEnumType.anger:
        return 'Anger';
      case EmotionEnumType.sadness:
        return 'Sadness';
      case EmotionEnumType.happiness:
        return 'Happiness';
      case EmotionEnumType.disgust:
        return 'Disgust';
      case EmotionEnumType.fear:
        return 'Fear';
      case EmotionEnumType.netral:
        return 'Neutral';
    }
  }

  Color get color {
    switch (this) {
      case EmotionEnumType.anger:
        return AppColors.emotionAnger;
      case EmotionEnumType.sadness:
        return AppColors.emotionSadness;
      case EmotionEnumType.happiness:
        return AppColors.emotionHappiness;
      case EmotionEnumType.disgust:
        return AppColors.emotionDisgust;
      case EmotionEnumType.fear:
        return AppColors.emotionFear;
      case EmotionEnumType.netral:
        return AppColors.emotionNetral;
    }
  }

  Color get surfaceColor {
    switch (this) {
      case EmotionEnumType.anger:
        return AppColors.emotionAngerSurface;
      case EmotionEnumType.sadness:
        return AppColors.emotionSadnessSurface;
      case EmotionEnumType.happiness:
        return AppColors.emotionHappinessSurface;
      case EmotionEnumType.disgust:
        return AppColors.emotionDisgustSurface;
      case EmotionEnumType.fear:
        return AppColors.emotionFearSurface;
      case EmotionEnumType.netral:
        return AppColors.emotionNetralSurface;
    }
  }

  Color get onColor {
    switch (this) {
      case EmotionEnumType.anger:
        return AppColors.onEmotionAnger;
      case EmotionEnumType.sadness:
        return AppColors.onEmotionSadness;
      case EmotionEnumType.happiness:
        return AppColors.onEmotionHappiness;
      case EmotionEnumType.disgust:
        return AppColors.onEmotionDisgust;
      case EmotionEnumType.fear:
        return AppColors.onEmotionFear;
      case EmotionEnumType.netral:
        return AppColors.onEmotionNetral;
    }
  }
}
