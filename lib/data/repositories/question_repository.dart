import 'package:fem_psychmonitor/features/onboarding/models/ocean_model.dart';
import 'package:fem_psychmonitor/features/onboarding/models/psych_model.dart';

abstract class QuestionRepository {
  Future<List<OceanQuestion>> getOceanQuestions();
  Future<PsychData> getPsychData();
  Future<PsychScoringSystem> getPsychClasses();
}
