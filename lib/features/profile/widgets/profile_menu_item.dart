import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;
  final bool showBorder;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? const Color(0xFFDC2626) : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (trailing != null)
                    trailing!
                  else if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.outlineVariant,
                      size: 24.sp,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showBorder)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.outline,
            indent: 16.w + 36.w + 16.w, // padding + icon container + spacing
            endIndent: 16.w,
          ),
      ],
    );
  }
}
