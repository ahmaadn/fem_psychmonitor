import 'package:fl_chart/fl_chart.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Stacked bar chart of daily session counts per emotion.
class EmotionHistoryChart extends StatelessWidget {
  const EmotionHistoryChart({super.key, required this.series, this.days = 7});

  final List<EmotionSeriesPoint> series;
  final int days;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (series.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl.h),
        child: Text(
          'Belum ada data chart.',
          style: AppTypography.caption.copyWith(color: p.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    final emotions = EmotionLabelType.values;
    final maxY = _maxStackedValue(series).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 180.h,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxY <= 0 ? 1 : maxY).toDouble(),
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final i = value.round();
                      if (i < 0 || i >= series.length) {
                        return const SizedBox.shrink();
                      }
                      final d = series[i].date;
                      return Padding(
                        padding: EdgeInsets.only(top: AppSpacing.xxs.h + 2),
                        child: Text(
                          '${d.day}/${d.month}',
                          style: AppTypography.label
                              .copyWith(color: p.textSecondary, fontSize: 9.sp),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: _buildGroups(context, emotions),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Wrap(
          spacing: AppSpacing.xs.w + 2,
          runSpacing: AppSpacing.xxs.h + 2,
          children: emotions
              .map(
                (e) => _legendChip(
                  p.emotionBase(e),
                  e.displayName,
                  p,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildGroups(
    BuildContext context,
    List<EmotionLabelType> emotions,
  ) {
    final p = context.palette;
    final groups = <BarChartGroupData>[];
    for (int i = 0; i < series.length; i++) {
      final point = series[i];
      final rods = <BarChartRodStackItem>[];
      double running = 0;
      for (final e in emotions) {
        final count = point.counts[e] ?? 0;
        if (count > 0) {
          rods.add(
            BarChartRodStackItem(
              running,
              running + count,
              p.emotionBase(e),
            ),
          );
          running += count;
        }
      }
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: running,
              width: 14.w,
              borderRadius: BorderRadius.circular(AppRadius.xs.r),
              rodStackItems: rods,
            ),
          ],
        ),
      );
    }
    return groups;
  }

  int _maxStackedValue(List<EmotionSeriesPoint> points) {
    int max = 0;
    for (final point in points) {
      if (point.total > max) max = point.total;
    }
    return max;
  }

  Widget _legendChip(Color color, String label, AppPalette p) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: AppSpacing.xxs.w),
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: p.textSecondary,
            fontSize: 10.sp,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}
