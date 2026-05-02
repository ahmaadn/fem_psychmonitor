import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 24.h),
        Text(
          title,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 32.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 15.sp,
            color: AppColors.onSurface,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
