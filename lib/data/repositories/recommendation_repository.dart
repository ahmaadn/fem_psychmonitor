import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/recommendation_engine.dart';
import 'package:fem_psychmonitor/features/onboarding/models/ocean_model.dart';

abstract class RecommendationRepository {
  Future<RecommendationResult> getRecommendations({
    required OceanScores? ocean,
    required EmotionLabelType emotion,
    required int? psychScore,
    required bool isEnglish,
    bool crisisExplicit = false,
  });
}
