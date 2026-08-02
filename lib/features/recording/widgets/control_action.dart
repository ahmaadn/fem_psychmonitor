import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ControlAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const ControlAction({
    super.key,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                if (bgColor == p.primaryFill)
                  BoxShadow(
                    color: p.primaryFill.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 28.sp),
          ),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Text(label, style: AppTypography.label.copyWith(color: p.primaryText)),
      ],
    );
  }
}
