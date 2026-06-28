import 'dart:convert';

import 'package:fem_psychmonitor/features/onboarding/models/localized_string_model.dart';
import 'package:fem_psychmonitor/features/onboarding/models/mbti_model.dart';
import 'package:fem_psychmonitor/features/onboarding/models/psych_model.dart';
import 'package:fem_psychmonitor/features/onboarding/models/saran_model.dart';

/// Row ⇄ model mappers for the asset-seeded master tables.
class MasterRow {
  MasterRow._();

  // ── MBTI ───────────────────────────────────────────────────────────────
  static Map<String, Object?> mbtiQuestionRow(MbtiQuestion q) => {
        'id': q.id,
        'code': q.code,
        'dimension': q.dimension,
        'question_en': q.question.en,
        'question_id': q.question.id,
      };

  static Map<String, Object?> mbtiOptionRow(int questionId, MbtiOption o) => {
        'question_id': questionId,
        'code': o.code,
        'answer_en': o.answer.en,
        'answer_id': o.answer.id,
        'type': o.type,
      };

  static MbtiQuestion mbtiQuestionFromRow(
    Map<String, Object?> qRow,
    List<Map<String, Object?>> optRows,
  ) {
    return MbtiQuestion(
      id: qRow['id'] as int,
      code: qRow['code'] as String? ?? '',
      dimension: qRow['dimension'] as String,
      question: LocalizedString(
        id: qRow['question_id'] as String,
        en: qRow['question_en'] as String,
      ),
      options: optRows
          .map((o) => MbtiOption(
                code: o['code'] as String? ?? '',
                answer: LocalizedString(
                  id: o['answer_id'] as String,
                  en: o['answer_en'] as String,
                ),
                type: o['type'] as String,
              ))
          .toList(),
    );
  }

  // ── Psych ──────────────────────────────────────────────────────────────
  static Map<String, Object?> psychQuestionRow(PsychQuestion q) => {
        'id': q.id,
        'code': q.code,
        'category_en': q.category.en,
        'category_id': q.category.id,
        'question_en': q.question.en,
        'question_id': q.question.id,
      };

  static Map<String, Object?> psychOptionRow(int questionId, PsychOption o) => {
        'question_id': questionId,
        'code': o.code,
        'answer_en': o.answer.en,
        'answer_id': o.answer.id,
        'score': o.score,
      };

  static Map<String, Object?> psychClassRow(PsychClass c) => {
        'class_level': c.classLevel,
        'class_name_en': c.className.en,
        'class_name_id': c.className.id,
        'display_range': c.displayRange,
        'score_range': c.scoreRange,
        'description_en': c.description.en,
        'description_id': c.description.id,
        'recommendation_en': c.recommendation.en,
        'recommendation_id': c.recommendation.id,
      };

  static PsychQuestion psychQuestionFromRow(
    Map<String, Object?> qRow,
    List<Map<String, Object?>> optRows,
  ) {
    return PsychQuestion(
      id: qRow['id'] as int,
      code: qRow['code'] as String? ?? '',
      category: LocalizedString(
        id: qRow['category_id'] as String,
        en: qRow['category_en'] as String,
      ),
      question: LocalizedString(
        id: qRow['question_id'] as String,
        en: qRow['question_en'] as String,
      ),
      options: optRows
          .map((o) => PsychOption(
                code: o['code'] as String? ?? '',
                answer: LocalizedString(
                  id: o['answer_id'] as String,
                  en: o['answer_en'] as String,
                ),
                score: o['score'] as int,
              ))
          .toList(),
    );
  }

  static PsychClass psychClassFromRow(Map<String, Object?> row) {
    return PsychClass(
      classLevel: row['class_level'] as int,
      className: LocalizedString(
        id: row['class_name_id'] as String,
        en: row['class_name_en'] as String,
      ),
      displayRange: row['display_range'] as String,
      scoreRange: row['score_range'] as String,
      description: LocalizedString(
        id: row['description_id'] as String,
        en: row['description_en'] as String,
      ),
      recommendation: LocalizedString(
        id: row['recommendation_id'] as String,
        en: row['recommendation_en'] as String,
      ),
    );
  }

  // ── Saran ──────────────────────────────────────────────────────────────
  static Map<String, Object?> saranRow(SaranRecommendation r) => {
        'mbti_type': r.mbtiType,
        'alias': r.alias,
        'group_name': r.group,
        'emotions_json': jsonEncode(_emotionsToJson(r.emotions)),
      };

  static SaranRecommendation saranFromRow(Map<String, Object?> row) {
    final emotions = SaranEmotions.fromJson(
      jsonDecode(row['emotions_json'] as String) as Map<String, dynamic>,
    );
    return SaranRecommendation(
      mbtiType: row['mbti_type'] as String,
      alias: row['alias'] as String,
      group: row['group_name'] as String,
      emotions: emotions,
    );
  }

  /// The source JSON uses the capitalised keys (Happy/Fear/Angry/...).
  static Map<String, dynamic> _emotionsToJson(SaranEmotions e) => {
        'Happy': e.happy,
        'Fear': e.fear,
        'Angry': e.angry,
        'Sad': e.sad,
        'Disgust': e.disgust,
        'Neutral': e.neutral,
      };
}
