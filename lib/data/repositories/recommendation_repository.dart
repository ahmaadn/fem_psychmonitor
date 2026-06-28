import 'package:fem_psychmonitor/features/onboarding/models/saran_model.dart';

/// Contract for fetching MBTI-tailored emotion recommendations (US-10).
///
/// Implementations: SqliteRecommendationRepository (asset-seeded SQLite),
/// (future) ApiRecommendationRepository. Master data, read-only at runtime.
abstract class RecommendationRepository {
  /// Get the recommendation set for [mbtiType] (e.g. "INTJ"). Returns null if
  /// no recommendation is seeded for the given type.
  Future<SaranRecommendation?> getSaran(String mbtiType);
}
