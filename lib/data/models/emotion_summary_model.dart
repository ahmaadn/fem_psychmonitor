import 'package:fem_psychmonitor/app/utils/emotion_config.dart';

/// Aggregated emotion statistics.
class EmotionSummaryModel {
  final EmotionLabelType emotion;
  final int count;
  final double percentage;
  final DateTime? latestDate;

  const EmotionSummaryModel({
    required this.emotion,
    required this.count,
    required this.percentage,
    this.latestDate,
  });
}

/// Represents a single day in the weekly check-in tracker.
class DailyCheckIn {
  final DateTime date;
  final bool isCheckedIn;
  final EmotionLabelType? dominantEmotion;

  const DailyCheckIn({
    required this.date,
    required this.isCheckedIn,
    this.dominantEmotion,
  });
}

/// Aggregated home screen statistics.
class HomeStats {
  final EmotionLabelType currentMood;
  final int currentMoodPercentage;
  final String moodDescription;
  final int totalRecordings;
  final int streakDays;
  final List<DailyCheckIn> weeklyCheckins;

  const HomeStats({
    required this.currentMood,
    required this.currentMoodPercentage,
    required this.moodDescription,
    required this.totalRecordings,
    required this.streakDays,
    required this.weeklyCheckins,
  });
}
