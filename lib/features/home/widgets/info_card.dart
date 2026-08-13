import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/session_card.dart';
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
    return SessionCard(
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.sp, color: p.primaryText),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyStrong.copyWith(
                    color: p.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Divider(height: 1, thickness: AppBorder.thin, color: p.divider),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            message,
            style: AppTypography.body.copyWith(
              color: p.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
