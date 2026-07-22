import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
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
    final p = context.palette;
    return Container(
      padding: EdgeInsets.all(AppSpacing.card.w),
      decoration: p.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.sp, color: p.primary),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                title,
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: p.ink,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Divider(
            height: 1,
            thickness: AppBorder.thin,
            color: p.hairline,
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            message,
            style: AppTypography.bodySm.copyWith(
              color: p.inkMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
