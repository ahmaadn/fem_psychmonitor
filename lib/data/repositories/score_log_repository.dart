import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';

class ScoreSeriesPoint {
  final DateTime at;
  final int score;
  final String reason;

  const ScoreSeriesPoint({
    required this.at,
    required this.score,
    required this.reason,
  });
}

class ScoreLogRepository {
  Future<void> append({
    required String userId,
    required int score,
    required String reason,
    DateTime? at,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(AppTables.mentalScoreLog, {
      'user_id': userId,
      'at_ms': (at ?? DateTime.now()).millisecondsSinceEpoch,
      'score': score.clamp(0, 100),
      'reason': reason,
    });
  }

  /// Last score per local day over [days], oldest → newest.
  Future<List<ScoreSeriesPoint>> getDailySeries({
    required String userId,
    int days = 7,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final cutoff =
        DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
    final rows = await db.query(
      AppTables.mentalScoreLog,
      where: 'user_id = ? AND at_ms >= ?',
      whereArgs: [userId, cutoff],
      orderBy: 'at_ms ASC',
    );

    final byDay = <String, ScoreSeriesPoint>{};
    for (final r in rows) {
      final at = DateTime.fromMillisecondsSinceEpoch(r['at_ms'] as int);
      final key =
          '${at.year}-${at.month.toString().padLeft(2, '0')}-${at.day.toString().padLeft(2, '0')}';
      byDay[key] = ScoreSeriesPoint(
        at: DateTime(at.year, at.month, at.day),
        score: r['score'] as int,
        reason: r['reason'] as String? ?? '',
      );
    }
    final list = byDay.values.toList()
      ..sort((a, b) => a.at.compareTo(b.at));
    return list;
  }
}
