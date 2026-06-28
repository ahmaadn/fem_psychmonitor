import 'package:fem_psychmonitor/features/onboarding/models/mbti_model.dart';
import 'package:fem_psychmonitor/features/onboarding/models/psych_model.dart';

/// Contract for reading onboarding master data (MBTI & Psych questionnaires).
///
/// Implementations: SqliteQuestionRepository (asset-seeded SQLite),
/// (future) ApiQuestionRepository. Master data is read-only at runtime.
abstract class QuestionRepository {
  Future<MbtiData> getMbtiData();

  Future<PsychData> getPsychData();

  /// The psych scoring classes (for result interpretation). Mirrors
  /// [PsychScoringSystem.classes] plus the normalisation scalars.
  Future<PsychScoringSystem> getPsychClasses();
}
