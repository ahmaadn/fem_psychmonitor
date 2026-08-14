import 'package:fem_psychmonitor/app/utils/date_utils.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/sync_queue_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/local/tables/user_row.dart';
import 'package:sqflite/sqflite.dart';

class DailyMoodRepository with SyncQueueHelper {
  Future<void> save({
    required String userId,
    required EmotionLabelType emotion,
    DateTime? day,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final date = dateKeyLocal(day ?? DateTime.now());
    final existing = await db.query(
      AppTables.dailyMoods,
      columns: ['created_at'],
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      limit: 1,
    );
    await db.insert(AppTables.dailyMoods, {
      'user_id': userId,
      'date': date,
      'emotion': emotion.name,
      'created_at': existing.isEmpty ? now : existing.first['created_at'],
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    final users = await db.query(
      AppTables.users,
      columns: [UserRow.colIsGuest],
      where: '${UserRow.colId} = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (users.isNotEmpty && (users.first[UserRow.colIsGuest] as int) == 0) {
      await enqueue(
        entityType: SyncEntity.dailyMood,
        entityId: date,
        operation: SyncOperation.update,
        payloadJson: syncPayloadJson({'emotion': emotion.name}),
      );
    }
  }

  Future<EmotionLabelType?> load(String userId, {DateTime? day}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final date = dateKeyLocal(day ?? DateTime.now());
      final rows = await db.query(
        AppTables.dailyMoods,
        where: 'user_id = ? AND date = ?',
        whereArgs: [userId, date],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final name = rows.first['emotion'] as String?;
      if (name == null) return null;
      return EmotionLabelType.values.firstWhere(
        (value) => value.name == name,
        orElse: () => EmotionLabelType.neutral,
      );
    } catch (_) {
      return null;
    }
  }
}
