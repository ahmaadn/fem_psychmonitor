import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: AppRadius.chip,
        border: Border.all(color: r.label.color.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(r.label.emoji, style: TextStyle(fontSize: 16.sp)),
          SizedBox(width: 8.w),
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: r.label.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            r.label.displayName,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: p.ink,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '${(r.confidence * 100).round()}%',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: r.label.color,
            ),
          ),
        ],
      ),
    );
  }
}
