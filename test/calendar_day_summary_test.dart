import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/calendar_day_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarDaySummary.dominant', () {
    test('returns the most frequent emotion', () {
      final s = CalendarDaySummary(
        date: DateTime(2026, 1, 1),
        counts: const {
          EmotionLabelType.happy: 7,
          EmotionLabelType.sad: 2,
          EmotionLabelType.anger: 1,
        },
      );
      expect(s.dominant, EmotionLabelType.happy);
      expect(s.total, 10);
      expect(s.dominantCount, 7);
      expect(s.dominantShare, closeTo(0.7, 1e-9));
      expect(s.isMixed, isTrue);
    });

    test('returns neutral when every label tied', () {
      final s = CalendarDaySummary(
        date: DateTime(2026, 1, 2),
        counts: const {
          EmotionLabelType.neutral: 1,
        },
      );
      expect(s.dominant, EmotionLabelType.neutral);
      expect(s.dominantShare, 1.0);
      expect(s.isMixed, isFalse);
    });

    test('tie-break prefers the lower enum index (not neutral)', () {
      // happy=0, neutral=5. A 1-1 tie without bias would pick neutral, which
      // is the least informative label on a mood calendar. The summary must
      // resolve ties toward the lower index instead.
      final s = CalendarDaySummary(
        date: DateTime(2026, 1, 3),
        counts: const {
          EmotionLabelType.happy: 1,
          EmotionLabelType.neutral: 1,
        },
      );
      expect(s.dominant, EmotionLabelType.happy);
    });

    test('presentByCount orders by count desc then enum index asc', () {
      final s = CalendarDaySummary(
        date: DateTime(2026, 1, 4),
        counts: const {
          EmotionLabelType.sad: 3, // index 1
          EmotionLabelType.happy: 3, // index 0 — wins tie on lower index
          EmotionLabelType.anger: 1,
        },
      );
      expect(
        s.presentByCount,
        const [
          EmotionLabelType.happy,
          EmotionLabelType.sad,
          EmotionLabelType.anger,
        ],
      );
    });
  });
}
