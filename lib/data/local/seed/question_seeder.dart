import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/local/tables/master_row.dart';
import 'package:fem_psychmonitor/features/onboarding/models/mbti_model.dart';
import 'package:fem_psychmonitor/features/onboarding/models/psych_model.dart';
import 'package:fem_psychmonitor/features/onboarding/models/saran_model.dart';
import 'package:sqflite/sqflite.dart';

/// Seeds the master / reference tables from `assets/questions/*.json` on first
/// run (when the tables are empty). Master data is **not** synced — it is
/// asset-sourced and read-only at runtime.
class QuestionSeeder {
  QuestionSeeder._();
  static final QuestionSeeder instance = QuestionSeeder._();

  /// Seed all master tables if empty. Safe to call on every launch.
  Future<void> seedIfEmpty() async {
    final db = await DatabaseHelper.instance.database;

    final mbtiCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${AppTables.mbtiQuestions}'),
        ) ??
        0;
    if (mbtiCount == 0) {
      await _seedMbti(db);
    }

    final psychCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${AppTables.psychQuestions}'),
        ) ??
        0;
    if (psychCount == 0) {
      await _seedPsych(db);
    }

    final saranCount = Sqflite.firstIntValue(
          await db
              .rawQuery('SELECT COUNT(*) FROM ${AppTables.saranRecommendations}'),
        ) ??
        0;
    if (saranCount == 0) {
      await _seedSaran(db);
    }
  }

  Future<void> _seedMbti(Database db) async {
    final raw =
        await rootBundle.loadString('assets/questions/mbti_localized.json');
    final data = MbtiData.fromJson(jsonDecode(raw) as Map<String, dynamic>);

    final batch = db.batch();
    for (final q in data.questionnaire) {
      batch.insert(
        AppTables.mbtiQuestions,
        MasterRow.mbtiQuestionRow(q),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final o in q.options) {
        batch.insert(
          AppTables.mbtiOptions,
          MasterRow.mbtiOptionRow(q.id, o),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedPsych(Database db) async {
    final raw =
        await rootBundle.loadString('assets/questions/psych_localized.json');
    final data = PsychData.fromJson(jsonDecode(raw) as Map<String, dynamic>);

    final batch = db.batch();
    for (final q in data.assessment.questions) {
      batch.insert(
        AppTables.psychQuestions,
        MasterRow.psychQuestionRow(q),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final o in q.options) {
        batch.insert(
          AppTables.psychOptions,
          MasterRow.psychOptionRow(q.id, o),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
    for (final c in data.assessment.scoringSystem.classes) {
      batch.insert(
        AppTables.psychClasses,
        MasterRow.psychClassRow(c),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    // Persist the scoring-system scalars used for score normalisation.
    batch.insert(AppTables.psychMeta, {'key': 'total_max_score', 'value': '${data.assessment.scoringSystem.totalMaxScore}'});
    batch.insert(AppTables.psychMeta, {'key': 'display_max_score', 'value': '${data.assessment.scoringSystem.displayMaxScore}'});
    batch.insert(AppTables.psychMeta, {'key': 'calculation', 'value': data.assessment.scoringSystem.calculation});
    await batch.commit(noResult: true);
  }

  Future<void> _seedSaran(Database db) async {
    final raw = await rootBundle.loadString('assets/questions/saran.json');
    final data = SaranData.fromJson(jsonDecode(raw) as Map<String, dynamic>);

    final batch = db.batch();
    for (final r in data.recommendations) {
      batch.insert(
        AppTables.saranRecommendations,
        MasterRow.saranRow(r),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
