import 'package:fem_psychmonitor/features/onboarding/models/localized_string_model.dart';

enum OceanTrait { o, c, e, a, n }

extension OceanTraitX on OceanTrait {
  String get code => name.toUpperCase();

  String get labelId => switch (this) {
    OceanTrait.o => 'Keterbukaan',
    OceanTrait.c => 'Kehati-hatian',
    OceanTrait.e => 'Ekstraversi',
    OceanTrait.a => 'Keramahan',
    OceanTrait.n => 'Neurotisisme',
  };

  String get labelEn => switch (this) {
    OceanTrait.o => 'Openness',
    OceanTrait.c => 'Conscientiousness',
    OceanTrait.e => 'Extraversion',
    OceanTrait.a => 'Agreeableness',
    OceanTrait.n => 'Neuroticism',
  };

  String label(bool isEnglish) => isEnglish ? labelEn : labelId;

  static OceanTrait parse(String raw) {
    switch (raw.toUpperCase()) {
      case 'O':
        return OceanTrait.o;
      case 'C':
        return OceanTrait.c;
      case 'E':
        return OceanTrait.e;
      case 'A':
        return OceanTrait.a;
      case 'N':
        return OceanTrait.n;
      default:
        return OceanTrait.o;
    }
  }
}

enum TraitLevel { low, neutral, high }

extension TraitLevelX on TraitLevel {
  String get key => name;
  String get labelId => switch (this) {
    TraitLevel.low => 'Rendah',
    TraitLevel.neutral => 'Netral',
    TraitLevel.high => 'Tinggi',
  };
  String get labelEn => switch (this) {
    TraitLevel.low => 'Low',
    TraitLevel.neutral => 'Neutral',
    TraitLevel.high => 'High',
  };
}

class OceanQuestion {
  final int id;
  final OceanTrait trait;
  final bool positiveKeyed;
  final LocalizedString statement;

  const OceanQuestion({
    required this.id,
    required this.trait,
    required this.positiveKeyed,
    required this.statement,
  });

  factory OceanQuestion.fromJson(Map<String, dynamic> json) {
    return OceanQuestion(
      id: json['id'] as int,
      trait: OceanTraitX.parse(json['trait'] as String),
      positiveKeyed: (json['keyed'] as String? ?? '+') == '+',
      statement: LocalizedString(
        en: json['statement_en'] as String? ?? json['statement'] as String,
        id: json['statement_id'] as String? ?? json['statement'] as String,
      ),
    );
  }

  int scoredValue(int raw1to5) {
    final v = raw1to5.clamp(1, 5);
    if (positiveKeyed) return v;
    return 6 - v;
  }
}

class OceanScores {
  final double o;
  final double c;
  final double e;
  final double a;
  final double n;

  const OceanScores({
    required this.o,
    required this.c,
    required this.e,
    required this.a,
    required this.n,
  });

  double scoreOf(OceanTrait t) => switch (t) {
    OceanTrait.o => o,
    OceanTrait.c => c,
    OceanTrait.e => e,
    OceanTrait.a => a,
    OceanTrait.n => n,
  };

  TraitLevel levelOf(OceanTrait t) => levelForScore(scoreOf(t));

  static TraitLevel levelForScore(double score) {
    if (score <= 2.79) return TraitLevel.low;
    if (score <= 3.20) return TraitLevel.neutral;
    return TraitLevel.high;
  }

  Map<String, double> toMap() => {'O': o, 'C': c, 'E': e, 'A': a, 'N': n};

  factory OceanScores.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const OceanScores(o: 3, c: 3, e: 3, a: 3, n: 3);
    }
    return OceanScores(
      o: (map['O'] as num?)?.toDouble() ?? 3,
      c: (map['C'] as num?)?.toDouble() ?? 3,
      e: (map['E'] as num?)?.toDouble() ?? 3,
      a: (map['A'] as num?)?.toDouble() ?? 3,
      n: (map['N'] as num?)?.toDouble() ?? 3,
    );
  }
}

/// Compute trait means from answered questions (raw 1–5).
OceanScores computeOceanScores(
  List<OceanQuestion> questions,
  Map<int, int> answers,
) {
  final sums = <OceanTrait, double>{for (final t in OceanTrait.values) t: 0};
  final counts = <OceanTrait, int>{for (final t in OceanTrait.values) t: 0};

  for (final q in questions) {
    final raw = answers[q.id];
    if (raw == null) continue;
    sums[q.trait] = sums[q.trait]! + q.scoredValue(raw);
    counts[q.trait] = counts[q.trait]! + 1;
  }

  double mean(OceanTrait t) {
    final c = counts[t]!;
    if (c == 0) return 3.0;
    return sums[t]! / c;
  }

  return OceanScores(
    o: mean(OceanTrait.o),
    c: mean(OceanTrait.c),
    e: mean(OceanTrait.e),
    a: mean(OceanTrait.a),
    n: mean(OceanTrait.n),
  );
}
