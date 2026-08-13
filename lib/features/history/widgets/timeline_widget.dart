import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_emoji.dart';
import 'package:fem_psychmonitor/app/widgets/linear_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TimelineSegment {
  final double startSec;
  double endSec;
  final EmotionLabelType label;
  int flex;

  TimelineSegment({
    required this.startSec,
    required this.endSec,
    required this.label,
    this.flex = 1,
  });

  @override
  String toString() =>
      '[${startSec.toStringAsFixed(1)}-${endSec.toStringAsFixed(1)}s] ${label.displayName}';
}

class RecordingTimeline extends StatelessWidget {
  const RecordingTimeline({super.key, required this.timeline});

  final List<EmotionResult> timeline;

  int _toFlex(double startSec, double endSec) {
    final duration = (endSec - startSec).clamp(0.0, double.infinity);
    return (duration * 10).round().clamp(1, 1000000);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final totalSec = timeline.isEmpty ? 0.0 : timeline.last.endSec;
    final totalLabel =
        '${(totalSec ~/ 60).toString().padLeft(2, '0')}:${(totalSec % 60).toInt().toString().padLeft(2, '0')} Total';

    List<TimelineSegment> segments = [];

    TimelineSegment? currentSegment;
    for (var i = 0; i < timeline.length; i++) {
      if (currentSegment == null) {
        currentSegment = TimelineSegment(
          startSec: timeline[i].startSec,
          endSec: timeline[i].endSec,
          label: timeline[i].label,
          flex: _toFlex(timeline[i].startSec, timeline[i].endSec),
        );
        segments.add(currentSegment);
        continue;
      }

      if (i == timeline.length - 1) {
        break; // Cegah out of range untuk nextResult
      }

      final nextResult = timeline[i + 1];
      if (timeline[i].label == nextResult.label) {
        // Jika label sama, perpanjang segmen saat ini
        currentSegment.endSec = nextResult.endSec;
        currentSegment.flex = _toFlex(
          currentSegment.startSec,
          currentSegment.endSec,
        );
      } else {
        // Jika label berbeda, buat segmen baru
        currentSegment = TimelineSegment(
          startSec: nextResult.startSec,
          endSec: nextResult.endSec,
          label: nextResult.label,
          flex: _toFlex(nextResult.startSec, nextResult.endSec),
        );
        segments.add(currentSegment);
      }
    }

    final segmentWidgets = timeline.isEmpty
        ? [
            Expanded(
              child: Container(color: p.primaryFill.withValues(alpha: 0.2)),
            ),
          ]
        : segments
              .map((e) {
                return Expanded(
                  flex: e.flex,
                  child: Container(color: p.emotionBase(e.label)),
                );
              })
              .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 20.sp,
                  color: p.primaryText.withValues(alpha: 0.8),
                ),
                SizedBox(width: 8.w),
                Text(
                  AppLocalizations.of(context)!.recordingTimeline,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              totalLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: p.primaryText.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: SizedBox(
            height: 10.h,
            width: double.infinity,
            child: Row(children: segmentWidgets),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.startTimeLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10.sp,
                color: p.primaryText.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.endTimeLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10.sp,
                color: p.primaryText.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ComponentTimeline extends StatelessWidget {
  final List<EmotionResult> timeline;
  final String title;
  final bool animateFromLastPercent;
  final bool sortByFrequency;
  final bool showAllEmotions;

  /// When true, bars show mean softmax confidence per emotion (overall
  /// confidence distribution). When false, bars show argmax label frequency.
  final bool useConfidenceDistribution;

  const ComponentTimeline({
    super.key,
    required this.timeline,
    this.title = 'Component Analysis',
    this.animateFromLastPercent = false,
    this.sortByFrequency = true,
    this.showAllEmotions = false,
    this.useConfidenceDistribution = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final Map<EmotionLabelType, int> emotionPercentages;

    if (useConfidenceDistribution) {
      final n = EmotionLabelType.values.length;
      final acc = List<double>.filled(n, 0);
      var count = 0;
      for (final item in timeline) {
        if (item.allProbs.length < n) continue;
        for (var i = 0; i < n; i++) {
          acc[i] += item.allProbs[i];
        }
        count++;
      }
      emotionPercentages = {
        for (final label in EmotionLabelType.values)
          label: count == 0 ? 0 : ((acc[label.index] / count) * 100).round(),
      };
      if (!showAllEmotions) {
        emotionPercentages.removeWhere((_, v) => v == 0);
      }
    } else {
      final countMap = <EmotionLabelType, int>{};
      if (showAllEmotions) {
        for (final label in EmotionLabelType.values) {
          countMap[label] = 0;
        }
      }

      for (final item in timeline) {
        countMap[item.label] = (countMap[item.label] ?? 0) + 1;
      }

      final total = timeline.isEmpty ? 1 : timeline.length;
      emotionPercentages = countMap.map(
        (key, value) => MapEntry(key, ((value / total) * 100).round()),
      );
    }

    final emotionEntries = emotionPercentages.entries.toList(growable: false);

    if (sortByFrequency) {
      emotionEntries.sort((a, b) => b.value.compareTo(a.value));
    } else {
      emotionEntries.sort((a, b) => a.key.index.compareTo(b.key.index));
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.relaxed.w),
      decoration: BoxDecoration(
        color: p.surface1,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: p.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 24.h),

          if (emotionEntries.isEmpty)
            Text(
              AppLocalizations.of(context)!.noEmotionComponents,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          for (var i = 0; i < emotionEntries.length; i++) ...[
            _buildEmotionProgressRow(
              context,
              emotion: emotionEntries[i].key,
              percentage: emotionEntries[i].value,
            ),
            if (i < emotionEntries.length - 1) SizedBox(height: 20.h),
          ],
        ],
      ),
    );
  }

  Widget _buildEmotionProgressRow(
    BuildContext context, {
    required EmotionLabelType emotion,
    required int percentage,
  }) {
    final p = context.palette;
    final base = p.emotionBase(emotion);
    final onE = p.emotionText(emotion);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                EmotionEmoji(asset: emotion.emojiAsset, size: 18),
                SizedBox(width: AppSpacing.xs.w),
                Text(
                  emotion.displayName,
                  style: AppTypography.bodyStrong.copyWith(
                    color: p.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              '$percentage%',
              style: AppTypography.bodyStrong.copyWith(color: onE),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm.h),
        LinearProgressBar(
          lineHeight: 8.h,
          percent: percentage / 100,
          duration: Duration(milliseconds: animateFromLastPercent ? 500 : 1000),
          animateFromLastPercent: animateFromLastPercent,
          backgroundColor: p.surface3,
          progressColor: base,
          barRadius: const Radius.circular(AppRadius.full),
        ),
      ],
    );
  }
}
