import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;

  /// Icon-chip color family, assigned by row category (DESIGN.md §4).
  /// A menu group must draw from at least three families — never all `primary`.
  final IconChipFamily chip;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showBorder;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.chip,
    this.onTap,
    this.trailing,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDestructive = chip == IconChipFamily.error;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md.w,
                vertical: AppSpacing.md.h,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.xs.w),
                    decoration: p.circle(
                      color: p.iconChipFill(chip),
                      borderColor: Colors.transparent,
                    ),
                    child: Icon(
                      icon,
                      color: p.iconChipIcon(chip),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? p.errorText : p.textPrimary,
                      ),
                    ),
                  ),
                  if (trailing != null)
                    trailing!
                  else if (onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: p.textTertiary,
                      size: 22.sp,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showBorder)
          Divider(
            height: 1,
            thickness: AppBorder.thin,
            color: p.divider,
            indent: AppSpacing.md.w + 36.w + AppSpacing.md.w,
            endIndent: AppSpacing.md.w,
          ),
      ],
    );
  }
}
