import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_emoji.dart';
import 'package:fem_psychmonitor/data/models/calendar_day_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One day cell in the Discover calendar.
///
/// A day with recordings shows the **dominant** emotion for that day (the most
/// frequently detected label — see [CalendarDaySummary.dominant]) as a large
/// emoji, with the date number demoted to a caption beneath it. A day without
/// recordings shows only the date number on a plain surface.
///
/// Sizing note: the tile is a rounded square rather than a circle. A circle
/// inscribed in the cell wastes ~21% of the available area, which is why the
/// previous emoji had to be shrunk to 14dp to fit alongside the date. The
/// squircle plus a taller aspect ratio lets the emoji render at
/// [emojiSize] (24dp) and stay legible.
class CalendarDayTile extends StatelessWidget {
  const CalendarDayTile({
    super.key,
    required this.date,
    required this.summary,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final CalendarDaySummary? summary;
  final bool isToday;
  final VoidCallback onTap;

  /// Emoji glyph size for a day that has recordings.
  static const double emojiSize = 24;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = summary;
    final hasData = s != null && s.total > 0;
    final emotion = hasData ? s.dominant : null;

    // Fill strength tracks how decisively the dominant emotion won the day:
    // a unanimous day reads stronger than a 4-vs-3 split.
    final base = emotion == null ? null : p.emotionBase(emotion);
    final fillAlpha = hasData ? _lerp(0.14, 0.30, s.dominantShare) : 0.0;

    final Color background;
    if (base != null) {
      background = base.withValues(alpha: fillAlpha);
    } else if (isToday) {
      background = p.surface3;
    } else {
      background = p.surface2;
    }

    final Color borderColor;
    final double borderWidth;
    if (isToday) {
      borderColor = p.primaryText;
      borderWidth = AppBorder.thick;
    } else if (base != null) {
      borderColor = base.withValues(alpha: 0.42);
      borderWidth = AppBorder.thin;
    } else {
      borderColor = p.divider;
      borderWidth = AppBorder.thin;
    }

    // Date text: emotion text-safe variant on a tinted tile (DESIGN.md §2.6 —
    // never the raw base color as text), primary on today, secondary otherwise.
    final Color dateColor;
    if (isToday) {
      dateColor = p.primaryText;
    } else if (emotion != null) {
      dateColor = p.emotionText(emotion);
    } else {
      dateColor = p.textSecondary;
    }

    return Semantics(
      button: true,
      label: _semanticsLabel(context),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (emotion != null) ...[
                EmotionEmoji(asset: emotion.emojiAsset, size: emojiSize),
                SizedBox(height: 1.h),
              ],
              Text(
                '${date.day}',
                style: (emotion != null
                        ? AppTypography.micro
                        : AppTypography.caption)
                    .copyWith(
                      color: dateColor,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      height: 1,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _semanticsLabel(BuildContext context) {
    final s = summary;
    final day = '${date.day}';
    if (s == null || s.total == 0) return day;
    return '$day, ${s.dominant.displayName}, '
        '${s.dominantCount}/${s.total}';
  }

  static double _lerp(double a, double b, double t) =>
      a + (b - a) * t.clamp(0.0, 1.0);
}
