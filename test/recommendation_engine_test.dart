import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/mental_health_score.dart';
import 'package:fem_psychmonitor/app/utils/recommendation_engine.dart';
import 'package:fem_psychmonitor/features/onboarding/models/localized_string_model.dart';
import 'package:fem_psychmonitor/features/onboarding/models/ocean_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mental health score PLAN §9', () {
    test('base scores', () {
      expect(emotionBaseScore(EmotionLabelType.happy), 8);
      expect(emotionBaseScore(EmotionLabelType.fearful), -8);
    });

    test('class keys', () {
      expect(psychClassKeyForScore(10), 'butuh_perhatian');
      expect(psychClassKeyForScore(80), 'sehat');
      expect(isSafetyScore(20), isTrue);
      expect(isSafetyScore(50), isFalse);
    });
  });

  group('OCEAN scoring', () {
    test('reverse keyed items', () {
      final q = OceanQuestion(
        id: 1,
        trait: OceanTrait.e,
        positiveKeyed: false,
        statement: LocalizedString(id: 'x', en: 'x'),
      );
      expect(q.scoredValue(1), 5);
      expect(q.scoredValue(5), 1);
      expect(q.scoredValue(3), 3);
    });

    test('trait levels', () {
      expect(OceanScores.levelForScore(2.5), TraitLevel.low);
      expect(OceanScores.levelForScore(3.0), TraitLevel.neutral);
      expect(OceanScores.levelForScore(4.0), TraitLevel.high);
    });
  });

  group('RecommendationEngine', () {
    final rows = [
      OceanSaranRow(
        id: 1,
        trait: OceanTrait.o,
        level: TraitLevel.high,
        emotionKey: 'happy',
        order: 1,
        textId: 'saran o high happy 1',
        textEn: 'tip o high happy 1',
      ),
      OceanSaranRow(
        id: 2,
        trait: OceanTrait.o,
        level: TraitLevel.high,
        emotionKey: 'happy',
        order: 2,
        textId: 'saran o high happy 2',
        textEn: 'tip o high happy 2',
      ),
      OceanSaranRow(
        id: 3,
        trait: OceanTrait.o,
        level: TraitLevel.high,
        emotionKey: 'happy',
        order: 3,
        textId: 'saran o high happy 3',
        textEn: 'tip o high happy 3',
      ),
    ];
    final defaults = [
      OceanSaranRow(
        id: 100,
        trait: OceanTrait.o,
        level: TraitLevel.neutral,
        emotionKey: 'neutral',
        order: 1,
        textId: 'default 1',
        textEn: 'default 1 en',
      ),
    ];
    final engine =
        RecommendationEngine(saranRows: rows, defaultNeutral: defaults);

    test('safety on low psych score', () {
      final r = engine.build(
        ocean: const OceanScores(o: 4, c: 3, e: 3, a: 3, n: 3),
        emotion: EmotionLabelType.happy,
        psychScore: 20,
        isEnglish: false,
      );
      expect(r.safetyTriggered, isTrue);
      expect(r.items.length, 3);
    });

    test('max 2 tips per trait', () {
      final r = engine.build(
        ocean: const OceanScores(o: 4.5, c: 3, e: 3, a: 3, n: 3),
        emotion: EmotionLabelType.happy,
        psychScore: 70,
        isEnglish: true,
      );
      expect(r.safetyTriggered, isFalse);
      expect(r.items.length, 2);
    });

    test('all neutral uses defaults', () {
      final r = engine.build(
        ocean: const OceanScores(o: 3, c: 3, e: 3, a: 3, n: 3),
        emotion: EmotionLabelType.neutral,
        psychScore: 70,
        isEnglish: false,
      );
      expect(r.items.first.text, 'default 1');
    });
  });
}
