import 'package:fl_chart/fl_chart.dart';
import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// US-19: a stacked bar chart showing daily session counts per emotion over
/// the last [days] days, built from [EmotionSeriesPoint] data.
class EmotionHistoryChart extends StatelessWidget {
  const EmotionHistoryChart({super.key, required this.series, this.days = 7});

  final List<EmotionSeriesPoint> series;
  final int days;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (series.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Text(
          'Belum ada data chart.',
          style: TextStyle(color: p.inkMuted, fontSize: 12.sp),
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
                        padding: EdgeInsets.only(top: 6.h),
                        child: Text(
                          '${d.day}/${d.month}',
                          style: TextStyle(fontSize: 9.sp, color: p.inkMuted),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: _buildGroups(emotions),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 6.h,
          children: emotions
              .map((e) => _legendChip(e.color, e.displayName))
              .toList(),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildGroups(List<EmotionLabelType> emotions) {
    final groups = <BarChartGroupData>[];
    for (int i = 0; i < series.length; i++) {
      final point = series[i];
      final rods = <BarChartRodStackItem>[];
      double running = 0;
      for (final e in emotions) {
        final count = point.counts[e] ?? 0;
        if (count > 0) {
          rods.add(BarChartRodStackItem(running, running + count, e.color));
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
              borderRadius: BorderRadius.circular(4),
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

  Widget _legendChip(Color color, String label) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: p.inkMuted),
            ),
          ],
        );
      },
    );
  }
}
