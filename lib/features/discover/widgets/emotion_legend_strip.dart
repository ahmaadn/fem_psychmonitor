import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compact horizontal swatch of the six emotion colors so users can decode
/// the calendar dots. Lives above the calendar scroll; collapses to a small
/// caption row on tight screens.
class EmotionLegendStrip extends StatelessWidget {
  const EmotionLegendStrip({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (compact) {
      return Wrap(
        spacing: AppSpacing.xs.w,
        runSpacing: AppSpacing.xxs.h,
        children: EmotionLabelType.values.map((e) => _Chip(e: e, p: p)).toList(),
      );
    }

    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageX.w),
        itemCount: EmotionLabelType.values.length,
        separatorBuilder: (_, _) => SizedBox(width: AppSpacing.xs.w),
        itemBuilder: (_, i) => _Chip(e: EmotionLabelType.values[i], p: p),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.e, required this.p});

  final EmotionLabelType e;
  final AppPalette p;

  @override
  Widget build(BuildContext context) {
    final base = p.emotionBase(e);
    final onE = p.emotionText(e);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: AppSpacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.14),
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmotionEmoji(asset: e.emojiAsset, size: 16),
          SizedBox(width: AppSpacing.xxs.w),
          Text(
            e.label,
            style: AppTypography.label.copyWith(color: onE),
          ),
        ],
      ),
    );
  }
}
