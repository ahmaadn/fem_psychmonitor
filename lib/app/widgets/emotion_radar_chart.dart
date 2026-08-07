import 'dart:math' as math;
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_emoji.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 6-axis radar for emotion distribution (order = [EmotionLabelType.values]).
class EmotionRadarChart extends StatelessWidget {
  const EmotionRadarChart({
    super.key,
    required this.values,
    this.height = 260,
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Text(title!, style: AppTypography.bodyStrong),
          SizedBox(height: AppSpacing.xs.h),
        ],
        SizedBox(
          height: height.h,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final box = constraints.biggest;
              // Asymmetric inset: top/bottom labels need more vertical room
              // because they stack emoji over text, while horizontal labels
              // sit to the side. This keeps all six inside the card.
              final insetX = 32.w;
              final insetY = 34.h;
              final innerW = (box.width - insetX * 2).clamp(1.0, box.width);
              final innerH = (box.height - insetY * 2).clamp(1.0, box.height);
              final radius = math.min(innerW / 2, innerH / 2) * 0.8;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: insetX,
                      vertical: insetY,
                    ),
                    child: RadarChart(
                      RadarChartData(
                        dataSets: [
                          RadarDataSet(
                            fillColor: p.primary.withValues(alpha: 0.22),
                            borderColor: p.primary,
                            entryRadius: 3,
                            borderWidth: 2,
                            dataEntries: data
                                .map((v) => RadarEntry(value: v))
                                .toList(),
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
                        // Titles are drawn by [_AxisLabels] so each axis can
                        // carry a raster emoji, which fl_chart's text-only
                        // titles cannot render.
                        titleTextStyle: AppTypography.caption.copyWith(
                          color: Colors.transparent,
                        ),
                        getTitle: (index, angle) =>
                            const RadarChartTitle(text: '', angle: 0),
                      ),
                    ),
                  ),
                  _AxisLabels(
                    center: Offset(box.width / 2, box.height / 2),
                    radius: radius,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Width/height reserved for one axis label (emoji stacked over its name).
final double _labelBoxW = 62.w;
final double _labelBoxH = 46.h;

/// Emoji + name rendered on each radar axis, just outside the outer ring.
///
/// Mirrors `RadarChartPainter` geometry: axis `i` of `n` sits at
/// `2πi / n - π/2`, measured from the chart center.
class _AxisLabels extends StatelessWidget {
  const _AxisLabels({required this.center, required this.radius});

  final Offset center;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final emotions = EmotionLabelType.values;
    // Sit just beyond the outer ring so labels never cover the plotted shape.
    final distance = radius * 1.18;

    return Stack(
      clipBehavior: Clip.none,
      children: List.generate(emotions.length, (i) {
        final e = emotions[i];
        final angle = (2 * math.pi / emotions.length) * i - math.pi / 2;
        final dx = center.dx + distance * math.cos(angle);
        final dy = center.dy + distance * math.sin(angle);

        return Positioned(
          left: dx - _labelBoxW / 2,
          top: dy - _labelBoxH / 2,
          width: _labelBoxW,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmotionEmoji(asset: e.emojiAsset, size: 22),
              SizedBox(height: AppSpacing.xxs.h / 2),
              Text(
                e.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(color: p.textSecondary),
              ),
            ],
          ),
        );
      }),
    );
  }
}
