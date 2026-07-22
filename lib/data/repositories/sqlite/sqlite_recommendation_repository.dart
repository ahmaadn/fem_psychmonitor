import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/recommendation_engine.dart';
import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/repositories/recommendation_repository.dart';
import 'package:fem_psychmonitor/features/onboarding/models/ocean_model.dart';

class SqliteRecommendationRepository extends RecommendationRepository {
  RecommendationEngine? _engine;

  Future<RecommendationEngine> _loadEngine() async {
    if (_engine != null) return _engine!;
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(AppTables.saranOcean, orderBy: 'id ASC');
    final saran = rows
        .map(
          (r) => OceanSaranRow(
            id: r['id'] as int,
            trait: OceanTraitX.parse(r['trait'] as String),
            level: (r['level'] as String) == 'high'
                ? TraitLevel.high
                : TraitLevel.low,
            emotionKey: (r['emotion'] as String).toLowerCase(),
            order: r['sort_order'] as int,
            textId: r['text_id'] as String,
            textEn: r['text_en'] as String,
          ),
        )
        .toList();
    final defRows =
        await db.query(AppTables.saranDefaultNeutral, orderBy: 'sort_order ASC');
    final defaults = defRows
        .map(
          (r) => OceanSaranRow(
            id: r['id'] as int,
            trait: OceanTrait.o,
            level: TraitLevel.neutral,
            emotionKey: 'neutral',
            order: r['sort_order'] as int,
            textId: r['text_id'] as String,
            textEn: r['text_en'] as String,
          ),
        )
        .toList();
    _engine = RecommendationEngine(saranRows: saran, defaultNeutral: defaults);
    return _engine!;
  }

  @override
  Future<RecommendationResult> getRecommendations({
    required OceanScores? ocean,
    required EmotionLabelType emotion,
    required int? psychScore,
    required bool isEnglish,
    bool crisisExplicit = false,
  }) async {
    final engine = await _loadEngine();
    return engine.build(
      ocean: ocean,
      emotion: emotion,
      psychScore: psychScore,
      isEnglish: isEnglish,
      crisisExplicit: crisisExplicit,
    );
  }
}
