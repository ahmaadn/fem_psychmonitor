import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
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
              borderRadius: BorderRadius.circular(
                AppRadius.xl,
              ), // Rounded square
              boxShadow: [
                if (bgColor ==
                    p.primary) // Tambah glow khusus tombol Done
                  BoxShadow(
                    color: p.primary.withAlpha(76),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 28.sp),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 12.sp,
            color: p.primary.withAlpha(204),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
