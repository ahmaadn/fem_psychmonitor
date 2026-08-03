import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compact realtime status strip. It keeps the current emotion visible without
/// turning the live detection area into another large card.
class EmotionBadge extends StatelessWidget {
  /// Hasil deteksi emosi yang akan ditampilkan.
  final EmotionResult result;

  const EmotionBadge({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = result;
    final emotionColor = p.emotionBase(r.label);
    final emotionText = p.emotionText(r.label);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w + 2.w,
        vertical: AppSpacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: AppRadius.chip,
        border: Border.all(color: emotionColor.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmotionEmoji(asset: r.label.emojiAsset, size: 18),
          SizedBox(width: AppSpacing.xs.w),
          Container(
            width: AppSpacing.xs.w,
            height: AppSpacing.xs.w,
            decoration: BoxDecoration(
              color: emotionColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          Text(
            r.label.displayName,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          Text(
            '${(r.confidence * 100).round()}%',
            style: AppTypography.label.copyWith(color: emotionText),
          ),
        ],
      ),
    );
  }
}
