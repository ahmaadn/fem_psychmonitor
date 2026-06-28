import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/local/tables/master_row.dart';
import 'package:fem_psychmonitor/data/repositories/question_repository.dart';
import 'package:fem_psychmonitor/features/onboarding/models/localized_string_model.dart';
import 'package:fem_psychmonitor/features/onboarding/models/mbti_model.dart';
import 'package:fem_psychmonitor/features/onboarding/models/psych_model.dart';

/// Reads onboarding master data from the asset-seeded SQLite tables.
class SqliteQuestionRepository extends QuestionRepository {
  @override
  Future<MbtiData> getMbtiData() async {
    final db = await DatabaseHelper.instance.database;
    final qRows = await db.query(
      AppTables.mbtiQuestions,
      orderBy: 'id ASC',
    );
    final questions = <MbtiQuestion>[];
    for (final q in qRows) {
      final optRows = await db.query(
        AppTables.mbtiOptions,
        where: 'question_id = ?',
        whereArgs: [q['id']],
        orderBy: 'id ASC',
      );
      questions.add(MasterRow.mbtiQuestionFromRow(q, optRows));
    }
    return MbtiData(questionnaire: questions);
  }

  @override
  Future<PsychData> getPsychData() async {
    final db = await DatabaseHelper.instance.database;
    final qRows = await db.query(
      AppTables.psychQuestions,
      orderBy: 'id ASC',
    );
    final questions = <PsychQuestion>[];
    for (final q in qRows) {
      final optRows = await db.query(
        AppTables.psychOptions,
        where: 'question_id = ?',
        whereArgs: [q['id']],
        orderBy: 'id ASC',
      );
      questions.add(MasterRow.psychQuestionFromRow(q, optRows));
    }
    final scoring = await getPsychClasses();
    // Title/description are surfaced via l10n in the UI, not the DB; pass empty
    // localised strings to satisfy the model constructor.
    final empty = LocalizedString(id: '', en: '');
    return PsychData(
      assessment: PsychAssessment(
        title: empty,
        description: empty,
        questions: questions,
        scoringSystem: scoring,
      ),
    );
  }

  @override
  Future<PsychScoringSystem> getPsychClasses() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      AppTables.psychClasses,
      orderBy: 'class_level ASC',
    );
    final classes = rows.map(MasterRow.psychClassFromRow).toList();

    final meta = <String, String>{};
    final metaRows = await db.query(AppTables.psychMeta);
    for (final r in metaRows) {
      meta[r['key'] as String] = r['value'] as String;
    }

    return PsychScoringSystem(
      totalMaxScore: int.tryParse(meta['total_max_score'] ?? '') ?? 0,
      displayMaxScore: int.tryParse(meta['display_max_score'] ?? '') ?? 0,
      calculation: meta['calculation'] ?? '',
      classes: classes,
    );
  }
}
