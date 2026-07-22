import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/local/tables/master_row.dart';
import 'package:fem_psychmonitor/features/onboarding/models/ocean_model.dart';
import 'package:fem_psychmonitor/features/onboarding/models/psych_model.dart';
import 'package:sqflite/sqflite.dart';

class QuestionSeeder {
  QuestionSeeder._();
  static final QuestionSeeder instance = QuestionSeeder._();

  Future<void> seedIfEmpty() async {
    final db = await DatabaseHelper.instance.database;

    final oceanCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${AppTables.oceanQuestions}'),
        ) ??
        0;
    if (oceanCount == 0) {
      await _seedOcean(db);
    }

    final psychCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${AppTables.psychQuestions}'),
        ) ??
        0;
    if (psychCount == 0) {
      await _seedPsych(db);
    }

    final saranCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ${AppTables.saranOcean}'),
        ) ??
        0;
    if (saranCount == 0) {
      await _seedSaranOcean(db);
    }
  }

  Future<void> forceReseedMaster() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(AppTables.oceanQuestions);
    await db.delete(AppTables.saranOcean);
    await db.delete(AppTables.saranDefaultNeutral);
    await _seedOcean(db);
    await _seedSaranOcean(db);
  }

  Future<void> _seedOcean(Database db) async {
    final raw = await rootBundle.loadString('assets/questions/ocean.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final list = map['questions'] as List;
    final batch = db.batch();
    for (final item in list) {
      final q = OceanQuestion.fromJson(item as Map<String, dynamic>);
      batch.insert(
        AppTables.oceanQuestions,
        {
          'id': q.id,
          'trait': q.trait.code,
          'positive_keyed': q.positiveKeyed ? 1 : 0,
          'statement_en': q.statement.en,
          'statement_id': q.statement.id,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
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
    batch.insert(AppTables.psychMeta, {
      'key': 'total_max_score',
      'value': '${data.assessment.scoringSystem.totalMaxScore}',
    });
    batch.insert(AppTables.psychMeta, {
      'key': 'display_max_score',
      'value': '${data.assessment.scoringSystem.displayMaxScore}',
    });
    batch.insert(AppTables.psychMeta, {
      'key': 'calculation',
      'value': data.assessment.scoringSystem.calculation,
    });
    await batch.commit(noResult: true);
  }

  Future<void> _seedSaranOcean(Database db) async {
    final raw =
        await rootBundle.loadString('assets/questions/saran_ocean.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final recs = map['recommendations'] as List;
    final batch = db.batch();
    for (final item in recs) {
      final m = item as Map<String, dynamic>;
      batch.insert(
        AppTables.saranOcean,
        {
          'id': m['id'],
          'trait': (m['trait'] as String).toUpperCase(),
          'level': m['level'],
          'emotion': (m['emotion'] as String).toLowerCase(),
          'sort_order': m['order'],
          'text_id': m['text_id'],
          'text_en': m['text_en'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    final defaults = map['default_neutral'] as List? ?? [];
    var i = 1;
    for (final item in defaults) {
      final m = item as Map<String, dynamic>;
      batch.insert(
        AppTables.saranDefaultNeutral,
        {
          'id': i,
          'sort_order': m['order'] ?? i,
          'text_id': m['text_id'],
          'text_en': m['text_en'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      i++;
    }
    await batch.commit(noResult: true);
  }
}
