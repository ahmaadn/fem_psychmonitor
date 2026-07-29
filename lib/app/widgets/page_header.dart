import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        SizedBox(height: AppSpacing.lg.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.display.copyWith(
            color: p.primaryText,
          ),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: p.textSecondary,
          ),
        ),
      ],
    );
  }
}
