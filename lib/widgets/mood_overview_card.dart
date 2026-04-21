import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/widgets/custom_badge.dart';
import 'package:flutter/material.dart';
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(76),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBadge(
                text: "TODAY'S SUMMARY",
                backgroundColor: Colors.white.withAlpha(51),
                textColor: Colors.white,
              ),

              Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
            ],
          ),

          SizedBox(height: 24.h),

          Text(
            '$percentage% $mood',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 48.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1.0,
            ),
          ),

          SizedBox(height: 12.h),

          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              color: Colors.white.withAlpha(230),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
