import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/local/tables/master_row.dart';
import 'package:fem_psychmonitor/data/repositories/recommendation_repository.dart';
import 'package:fem_psychmonitor/features/onboarding/models/saran_model.dart';

/// Reads MBTI-tailored emotion recommendations (US-10) from the asset-seeded
/// `saran_recommendations` table.
class SqliteRecommendationRepository extends RecommendationRepository {
  @override
  Future<SaranRecommendation?> getSaran(String mbtiType) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      AppTables.saranRecommendations,
      where: 'mbti_type = ?',
      whereArgs: [mbtiType.toUpperCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MasterRow.saranFromRow(rows.first);
  }
}
