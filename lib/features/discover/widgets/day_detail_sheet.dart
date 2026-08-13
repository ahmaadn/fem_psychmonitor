import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/widgets/app_bottom_sheet.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_emoji.dart';
import 'package:fem_psychmonitor/data/models/calendar_day_summary.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Bottom sheet shown when the user taps a day on the Discover calendar.
///
/// Two states:
/// - **Empty** day: shows a primary CTA so the user can record their mood
///   for that day.
/// - **Day with recordings**: shows the per-emotion tally (with the dominant
///   emotion surfaced first) and a scrollable list of sessions for that day.
class DayDetailSheet extends StatelessWidget {
  const DayDetailSheet({
    super.key,
    required this.day,
    required this.summary,
    required this.sessions,
    required this.onPickMood,
  });

  final DateTime day;
  final CalendarDaySummary? summary;
  final List<DetectionSessionModel> sessions;
  final VoidCallback onPickMood;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final hasData = sessions.isNotEmpty;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, controller) {
        if (!hasData) {
          return _EmptyBody(
            day: day,
            locale: locale,
            l10n: l10n,
            onPickMood: onPickMood,
          );
        }

        return ListView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg.w,
            AppSpacing.sm.h,
            AppSpacing.lg.w,
            AppSpacing.xxl.h,
          ),
          children: [
            const AppSheetHandle(),
            SizedBox(height: AppSpacing.md.h),
            Text(
              DateFormat.yMMMMd(locale).format(day),
              style: AppTypography.subtitle.copyWith(color: p.textPrimary),
            ),
            SizedBox(height: AppSpacing.xs.h),
            if (summary != null)
              _DaySummaryRow(summary: summary!, l10n: l10n),
            SizedBox(height: AppSpacing.sm.h),
            for (final s in sessions) ...[
              _SessionRow(session: s, locale: locale),
              SizedBox(height: AppSpacing.xs.h),
            ],
          ],
        );
      },
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({
    required this.day,
    required this.locale,
    required this.l10n,
    required this.onPickMood,
  });

  final DateTime day;
  final String locale;
  final AppLocalizations l10n;
  final VoidCallback onPickMood;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: EdgeInsets.all(AppSpacing.pageX.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSheetHandle(),
          SizedBox(height: AppSpacing.md.h),
          Text(
            DateFormat.yMMMMd(locale).format(day),
            style: AppTypography.subtitle.copyWith(color: p.textPrimary),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            l10n.discoverEmptyDay,
            style: AppTypography.caption.copyWith(color: p.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg.h),
          PrimaryButton(
            text: l10n.discoverRecordMoodCta,
            onPressed: onPickMood,
          ),
        ],
      ),
    );
  }
}

class _DaySummaryRow extends StatelessWidget {
  const _DaySummaryRow({required this.summary, required this.l10n});

  final CalendarDaySummary summary;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ordered = summary.presentByCount;
    if (ordered.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.xxs.w,
      runSpacing: AppSpacing.xxs.h,
      children: ordered.map((e) {
        final count = summary.counts[e] ?? 0;
        final base = p.emotionBase(e);
        final onE = p.emotionText(e);
        final isDominant = e == summary.dominant;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: AppSpacing.xxs.h,
          ),
          decoration: BoxDecoration(
            color: base.withValues(alpha: isDominant ? 0.22 : 0.12),
            borderRadius: AppRadius.chip,
            border: Border.all(
              color: base.withValues(alpha: isDominant ? 0.45 : 0.25),
              width: isDominant ? AppBorder.medium : AppBorder.thin,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmotionEmoji(asset: e.emojiAsset, size: 16),
              SizedBox(width: AppSpacing.xxs.w),
              Text(
                '${e.displayName}: $count',
                style: AppTypography.caption.copyWith(
                  color: p.isDark ? onE : p.textPrimary,
                  fontWeight: isDominant ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session, required this.locale});

  final DetectionSessionModel session;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final emotion = session.displayEmotion;
    final base = p.emotionBase(emotion);
    final onE = p.emotionText(emotion);

    return Container(
      decoration: BoxDecoration(
        color: p.surface1,
        borderRadius: AppRadius.card,
        border: Border.all(color: p.divider),
      ),
      child: ListTile(
        leading: Container(
          width: 40.w,
          height: 40.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: base.withValues(alpha: 0.15),
            borderRadius: AppRadius.tile,
          ),
          child: EmotionEmoji(asset: emotion.emojiAsset, size: 22),
        ),
        title: Text(
          emotion.displayName,
          style: AppTypography.bodyStrong.copyWith(color: p.textPrimary),
        ),
        subtitle: Text(
          '${session.duration.inMinutes}m '
          '${session.duration.inSeconds % 60}s · '
          '${DateFormat.Hm(locale).format(session.startedAt)}',
          style: AppTypography.caption.copyWith(color: p.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // DESIGN.md §4 Mood Check-in Card: confidence rendered in the
            // emotion's text-safe variant, never the raw base color.
            Text(
              '${(session.displayConfidence * 100).round()}%',
              style: AppTypography.caption.copyWith(
                color: onE,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: AppSpacing.xxs.w),
            Icon(
              Icons.chevron_right_rounded,
              color: p.textTertiary,
              size: 18.sp,
            ),
          ],
        ),
        onTap: () {
          Navigator.pop(context);
          context.pushNamed(
            RouteNames.analysisResult,
            extra: session.id,
          );
        },
      ),
    );
  }
}

/// Convenience: open the day-detail sheet from anywhere.
Future<void> showDayDetailSheet({
  required BuildContext context,
  required DateTime day,
  required CalendarDaySummary? summary,
  required List<DetectionSessionModel> sessions,
  required VoidCallback onPickMood,
}) {
  return showAppBottomSheet<void>(
    context: context,
    builder: (_) => DayDetailSheet(
      day: day,
      summary: summary,
      sessions: sessions,
      onPickMood: onPickMood,
    ),
  );
}
