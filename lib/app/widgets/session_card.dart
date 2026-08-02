import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Session / journal card shell — surface-1, 18dp radius, 16dp padding.
class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.elevated = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final content = Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(AppSpacing.card.r),
      decoration: p.card(
        radius: AppRadius.lg.r,
        elevated: elevated,
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        child: content,
      ),
    );
  }
}

/// Mood check-in card: session shell + 40dp emotion chip + title/meta/metric.
class MoodCheckInCard extends StatelessWidget {
  const MoodCheckInCard({
    super.key,
    required this.emotion,
    required this.title,
    this.subtitle,
    this.confidence,
    this.onTap,
    this.trailing,
  });

  final EmotionLabelType emotion;
  final String title;
  final String? subtitle;
  final double? confidence;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final base = p.emotionBase(emotion);
    final onE = p.emotionText(emotion);

    return SessionCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: base.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md.r),
            ),
              child: Text(
              emotion.emoji,
              style: AppTypography.emojiLg,
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.subtitle.copyWith(color: p.textPrimary),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppSpacing.xxs.h),
                  Text(
                    subtitle!,
                    style:
                        AppTypography.caption.copyWith(color: p.textTertiary),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (confidence != null)
            Text(
              '${(confidence! * 100).round()}%',
              style: AppTypography.metric.copyWith(color: onE),
            ),
        ],
      ),
    );
  }
}
