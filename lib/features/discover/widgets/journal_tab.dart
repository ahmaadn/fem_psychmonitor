import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/mental_score_line_chart.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/score_log_repository.dart';
import 'package:fem_psychmonitor/features/history/widgets/emotion_history_chart.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Right tab of the Discover screen: period selector, emotion distribution
/// chart, mental-score line chart, recording count.
class JournalTab extends StatelessWidget {
  const JournalTab({
    super.key,
    required this.periodDays,
    required this.onPeriodChanged,
    required this.series,
    required this.scoreSeries,
    required this.sessions,
  });

  final int periodDays;
  final ValueChanged<int> onPeriodChanged;
  final List<EmotionSeriesPoint> series;
  final List<ScoreSeriesPoint> scoreSeries;
  final List<DetectionSessionModel> sessions;

  static const _periods = <int, String>{7: '7d', 30: '1m', 180: '6m', 365: '1y'};

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageX.w,
        AppSpacing.md.h,
        AppSpacing.pageX.w,
        80.h,
      ),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _periods.entries.map((e) {
              final selected = periodDays == e.key;
              return Padding(
                padding: EdgeInsets.only(right: AppSpacing.xs.w),
                child: GestureDetector(
                  onTap: () => onPeriodChanged(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md.w,
                      vertical: AppSpacing.xs.h,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? p.primarySoft : p.surface1,
                      borderRadius: AppRadius.chip,
                      border: Border.all(
                        color: selected ? p.primaryText : p.divider,
                        width: AppBorder.thin,
                      ),
                    ),
                    child: Text(
                      e.value,
                      style: AppTypography.label.copyWith(
                        color: selected ? p.primaryText : p.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: AppSpacing.lg.h),
        _ChartSection(
          title: l10n.discoverEmotionDistribution,
          icon: Icons.bar_chart_rounded,
          child: EmotionHistoryChart(series: series, days: periodDays),
        ),
        SizedBox(height: AppSpacing.md.h),
        _ChartSection(
          title: l10n.discoverScoreHistory,
          icon: Icons.show_chart_rounded,
          child: MentalScoreLineChart(series: scoreSeries),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: AppSpacing.xxs.h,
          ),
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: AppRadius.chip,
          ),
          child: Text(
            '${l10n.discoverRecordingsLabel}: ${sessions.length}',
            style: AppTypography.caption.copyWith(
              color: p.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSpacing.xxl.w,
                height: AppSpacing.xxl.w,
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: BorderRadius.circular(AppRadius.sm.r),
                ),
                child: Icon(
                  icon,
                  color: p.textPrimary,
                  size: AppSpacing.sm.sp,
                ),
              ),
              SizedBox(width: AppSpacing.xs.w),
              Text(
                title,
                style: AppTypography.bodyStrong.copyWith(
                  color: p.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          child,
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.card.r),
      decoration: BoxDecoration(
        color: p.surface1,
        borderRadius: AppRadius.card,
        border: p.isDark ? null : Border.all(color: p.divider),
        boxShadow: p.cardShadow,
      ),
      child: child,
    );
  }
}
