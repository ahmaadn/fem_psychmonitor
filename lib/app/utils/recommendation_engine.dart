import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/mental_health_score.dart';
import 'package:fem_psychmonitor/features/onboarding/models/ocean_model.dart';

class OceanSaranRow {
  final int id;
  final OceanTrait trait;
  final TraitLevel level;
  final String emotionKey;
  final int order;
  final String textId;
  final String textEn;

  const OceanSaranRow({
    required this.id,
    required this.trait,
    required this.level,
    required this.emotionKey,
    required this.order,
    required this.textId,
    required this.textEn,
  });

  String text(bool isEnglish) => isEnglish ? textEn : textId;
}

class SaranItem {
  final String text;
  final OceanTrait? trait;
  final bool isSafety;

  const SaranItem({
    required this.text,
    this.trait,
    this.isSafety = false,
  });
}

class RecommendationResult {
  final bool safetyTriggered;
  final List<SaranItem> items;

  const RecommendationResult({
    required this.safetyTriggered,
    required this.items,
  });
}

/// Map model emotion enum → saran table emotion key.
String emotionSaranKey(EmotionLabelType e) {
  switch (e) {
    case EmotionLabelType.happy:
      return 'happy';
    case EmotionLabelType.sad:
      return 'sad';
    case EmotionLabelType.anger:
      return 'angry';
    case EmotionLabelType.fearful:
      return 'fear';
    case EmotionLabelType.disgust:
      return 'disgust';
    case EmotionLabelType.neutral:
      return 'neutral';
  }
}

class RecommendationEngine {
  RecommendationEngine({
    required this.saranRows,
    required this.defaultNeutral,
  });

  final List<OceanSaranRow> saranRows;
  final List<OceanSaranRow> defaultNeutral;

  RecommendationResult build({
    required OceanScores? ocean,
    required EmotionLabelType emotion,
    required int? psychScore,
    required bool isEnglish,
    bool crisisExplicit = false,
  }) {
    if (crisisExplicit || isSafetyScore(psychScore)) {
      return RecommendationResult(
        safetyTriggered: true,
        items: [
          SaranItem(
            isSafety: true,
            text: isEnglish
                ? 'Contact Sejiwa (psychological support) at 119 extension 8 — available 24 hours.'
                : 'Hubungi Sejiwa (layanan bantuan psikologis) di 119 ekstensi 8 — tersedia 24 jam.',
          ),
          SaranItem(
            isSafety: true,
            text: isEnglish
                ? 'If there is immediate danger, call local emergency services (110/118).'
                : 'Jika ada bahaya langsung terhadap keselamatan, segera hubungi layanan darurat setempat (110/118).',
          ),
          SaranItem(
            isSafety: true,
            text: isEnglish
                ? 'Find one trusted person to stay with you until professional help is available.'
                : 'Cari satu orang yang kamu percaya untuk menemani sampai bantuan profesional tersedia.',
          ),
        ],
      );
    }

    if (ocean == null) {
      return RecommendationResult(
        safetyTriggered: false,
        items: defaultNeutral
            .take(5)
            .map((r) => SaranItem(text: r.text(isEnglish)))
            .toList(),
      );
    }

    final emotionKey = emotionSaranKey(emotion);
    final ranked = OceanTrait.values
        .map((t) {
          final s = ocean.scoreOf(t);
          return (trait: t, score: s, level: ocean.levelOf(t), dev: (s - 3.0).abs());
        })
        .where((x) => x.level != TraitLevel.neutral)
        .toList()
      ..sort((a, b) => b.dev.compareTo(a.dev));

    if (ranked.isEmpty) {
      return RecommendationResult(
        safetyTriggered: false,
        items: defaultNeutral
            .take(5)
            .map((r) => SaranItem(text: r.text(isEnglish)))
            .toList(),
      );
    }

    final items = <SaranItem>[];
    for (final r in ranked) {
      final tips = saranRows
          .where((row) =>
              row.trait == r.trait &&
              row.level == r.level &&
              row.emotionKey == emotionKey)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      for (final tip in tips.take(2)) {
        items.add(SaranItem(text: tip.text(isEnglish), trait: r.trait));
      }
    }

    if (items.isEmpty) {
      return RecommendationResult(
        safetyTriggered: false,
        items: defaultNeutral
            .take(5)
            .map((r) => SaranItem(text: r.text(isEnglish)))
            .toList(),
      );
    }

    return RecommendationResult(safetyTriggered: false, items: items);
  }
}
