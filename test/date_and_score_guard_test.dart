import 'package:fem_psychmonitor/app/utils/date_utils.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/mental_health_score.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isSameLocalDay', () {
    test('same calendar day', () {
      final a = DateTime(2026, 7, 14, 1);
      final b = DateTime(2026, 7, 14, 23);
      expect(isSameLocalDay(a, b), isTrue);
    });

    test('different day', () {
      final a = DateTime(2026, 7, 14, 23);
      final b = DateTime(2026, 7, 15, 0);
      expect(isSameLocalDay(a, b), isFalse);
    });
  });

  group('PLAN score correction', () {
    DetectionSessionModel session({
      required EmotionLabelType emotion,
      required double conf,
      EmotionLabelType? corrected,
    }) {
      return DetectionSessionModel(
        id: 's1',
        userId: 'u1',
        startedAt: DateTime.now(),
        stoppedAt: DateTime.now(),
        sourceType: DetectionSourceType.live,
        dominantEmotion: emotion,
        dominantConfidence: conf,
        results: const [],
        correctedEmotion: corrected,
      );
    }

    test('uncorrected = base * confidence', () {
      final s = session(emotion: EmotionLabelType.happy, conf: 0.5);
      expect(detectionMentalHealthDelta(s), closeTo(4.0, 0.001));
    });

    test('corrected = 0.6 * base', () {
      final s = session(
        emotion: EmotionLabelType.happy,
        conf: 0.9,
        corrected: EmotionLabelType.sad,
      );
      // display becomes sad; base -6 * 0.6 = -3.6
      expect(detectionMentalHealthDelta(s), closeTo(-3.6, 0.001));
    });

    test('apply delta clamp', () {
      final s = session(emotion: EmotionLabelType.fearful, conf: 1.0);
      final next = applyDetectionMentalHealthImpact(
        currentScore: 5,
        session: s,
      );
      expect(next, 0); // 5 + (-8) clamped
    });
  });
}
