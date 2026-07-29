import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/session_card.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MoodOverviewCard extends StatelessWidget {
  final String mood;
  final String description;
  final int percentage;

  const MoodOverviewCard({
    super.key,
    required this.mood,
    required this.description,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SessionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.todaysSummary.toUpperCase(),
                style: AppTypography.label.copyWith(color: p.primaryText),
              ),
              Icon(
                Icons.auto_awesome_rounded,
                color: p.primaryText,
                size: 24.sp,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            '$percentage% $mood',
            style: AppTypography.metric.copyWith(color: p.primaryText),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            description,
            style: AppTypography.caption.copyWith(color: p.textSecondary),
          ),
        ],
      ),
    );
  }
}
