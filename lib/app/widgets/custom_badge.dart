import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final Color? iconColor;
  final Color? borderColor;

  const CustomBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.iconColor,
    this.borderColor,
  });

  static CustomBadge strawberry(BuildContext context, String text,
      {IconData? icon}) {
    final p = context.palette;
    return CustomBadge(
      text: text,
      backgroundColor: p.primarySoft,
      textColor: p.primaryText,
      borderColor: p.divider,
      icon: icon,
      iconColor: p.primaryText,
    );
  }

  static CustomBadge matcha(BuildContext context, String text,
      {IconData? icon}) {
    final p = context.palette;
    return CustomBadge(
      text: text,
      backgroundColor: p.secondaryWash,
      textColor: p.secondaryText,
      borderColor: p.secondary.withValues(alpha: 0.25),
      icon: icon,
      iconColor: p.secondaryText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: AppSpacing.xxs.h + 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.chip,
        border: Border.all(
          color: borderColor ?? p.divider,
          width: AppBorder.thin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: iconColor ?? textColor),
            SizedBox(width: AppSpacing.xxs.w),
          ],
          Text(
            text,
            style: AppTypography.label.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
