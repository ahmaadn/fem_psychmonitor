import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
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
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        // Surface putih bersih di atas background abu-abu (layering principle)
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        // Border tipis outline, bukan shadow (Borders over Shadows)
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                title,
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          // Divider tipis pemisah judul & isi
          Divider(height: 1, thickness: 1, color: AppColors.outline),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            message,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
