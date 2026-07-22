import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/custom_badge.dart';
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: p.panelStrawberry(radius: AppRadius.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBadge.strawberry(context, 
                AppLocalizations.of(context)!.todaysSummary,
              ),
              Icon(
                Icons.auto_awesome_rounded,
                color: p.primary,
                size: 24.sp,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg.h),
          Text(
            '$percentage% $mood',
            style: AppTypography.heroDisplay.copyWith(
              color: p.primaryFocus,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            description,
            style: AppTypography.caption.copyWith(
              color: p.inkMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
