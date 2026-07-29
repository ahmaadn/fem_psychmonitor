import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 6-axis radar for emotion distribution (order = [EmotionLabelType.values]).
class EmotionRadarChart extends StatelessWidget {
  const EmotionRadarChart({
    super.key,
    required this.values,
    this.height = 220,
    this.title,
  });

  /// Length 6, each 0..1 (or any non-negative; normalized to max).
  final List<double> values;
  final double height;
  final String? title;

  static List<double> averageProbsFromResults(
    Iterable<List<double>> allProbsList,
  ) {
    final acc = List<double>.filled(EmotionLabelType.values.length, 0);
    var n = 0;
    for (final p in allProbsList) {
      if (p.length < acc.length) continue;
      for (var i = 0; i < acc.length; i++) {
        acc[i] += p[i];
      }
      n++;
    }
    if (n == 0) return acc;
    return acc.map((v) => v / n).toList();
  }

  /// Softmax probs from the most recent detection window (live snapshot).
  static List<double> latestProbsFromResult(EmotionResult? result) {
    final n = EmotionLabelType.values.length;
    if (result == null || result.allProbs.length < n) {
      return List<double>.filled(n, 0);
    }
    return result.allProbs.take(n).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final raw = List<double>.generate(
      EmotionLabelType.values.length,
      (i) => i < values.length ? values[i].clamp(0.0, 1.0) : 0.0,
    );
    final maxV = raw.fold<double>(0, (a, b) => a > b ? a : b);
    final scale = maxV > 0 ? maxV : 1.0;
    final data = raw.map((v) => v / scale).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Text(title!, style: AppTypography.bodyStrong),
          SizedBox(height: 8.h),
        ],
        SizedBox(
          height: height.h,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  fillColor: p.primary.withValues(alpha: 0.22),
                  borderColor: p.primary,
                  entryRadius: 3,
                  borderWidth: 2,
                  dataEntries: data.map((v) => RadarEntry(value: v)).toList(),
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: BorderSide(color: p.divider, width: 1),
              tickBorderData: BorderSide(
                color: p.divider.withValues(alpha: 0.6),
              ),
              gridBorderData: BorderSide(color: p.divider, width: 1),
              ticksTextStyle: AppTypography.micro.copyWith(
                color: Colors.transparent,
              ),
              tickCount: 4,
              titleTextStyle: AppTypography.caption.copyWith(
                color: p.textSecondary,
              ),
              getTitle: (index, angle) {
                final e = EmotionLabelType.values[index];
                return RadarChartTitle(
                  text: '${e.emoji}\n${e.displayName}',
                  angle: 0,
                );
              },
              titlePositionPercentageOffset: 0.18,
            ),
          ),
        ),
      ],
    );
  }
}
