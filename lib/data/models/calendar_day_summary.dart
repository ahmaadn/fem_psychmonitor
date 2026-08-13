import 'package:fem_psychmonitor/app/utils/emotion_config.dart';

/// Aggregated emotion data for a single calendar day.
///
/// The Discover calendar renders one tile per day. A day can hold many
/// recordings, so the tile needs (a) the single emotion that best represents
/// the day and (b) enough context to show how strongly it dominates.
///
/// Example: 10 recordings on the 1st, 7 detected as happy, 3 spread across
/// other labels → [dominant] is happy, [total] is 10, [dominantCount] is 7,
/// [dominantShare] is 0.7.
class CalendarDaySummary {
  /// Local midnight for the day this summary describes.
  final DateTime date;

  /// Per-label recording counts. Labels with zero recordings are omitted.
  final Map<EmotionLabelType, int> counts;

  const CalendarDaySummary({required this.date, required this.counts});

  /// Total recordings on this day.
  int get total => counts.values.fold(0, (a, b) => a + b);

  /// The most frequent emotion of the day.
  ///
  /// Ties resolve toward the **lower** [EmotionLabelType] index. That is
  /// deliberate: it keeps the result deterministic and biases away from
  /// `neutral` (the last index), which is the least informative label to show
  /// a user on a mood calendar.
  EmotionLabelType get dominant {
    EmotionLabelType best = EmotionLabelType.neutral;
    var bestCount = -1;
    for (final e in EmotionLabelType.values) {
      final c = counts[e];
      if (c == null || c == 0) continue;
      if (c > bestCount) {
        best = e;
        bestCount = c;
      }
    }
    return best;
  }

  /// Number of recordings backing [dominant].
  int get dominantCount => counts[dominant] ?? 0;

  /// Fraction of the day's recordings that carried [dominant] (0.0–1.0).
  ///
  /// Used to modulate tile fill strength so a unanimous day reads stronger
  /// than a narrowly-won one.
  double get dominantShare {
    final t = total;
    if (t == 0) return 0;
    return dominantCount / t;
  }

  /// True when more than one distinct emotion was recorded on this day.
  bool get isMixed => counts.values.where((c) => c > 0).length > 1;

  /// Labels present on this day, ordered by count descending then enum index.
  List<EmotionLabelType> get presentByCount {
    final present = EmotionLabelType.values
        .where((e) => (counts[e] ?? 0) > 0)
        .toList();
    present.sort((a, b) {
      final byCount = (counts[b] ?? 0).compareTo(counts[a] ?? 0);
      if (byCount != 0) return byCount;
      return a.index.compareTo(b.index);
    });
    return present;
  }
}
