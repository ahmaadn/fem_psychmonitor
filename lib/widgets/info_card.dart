import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const InfoCard({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Off-white / Slate 50
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary.withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13.sp,
              color: AppColors.primary.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
