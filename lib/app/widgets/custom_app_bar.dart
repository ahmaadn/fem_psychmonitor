import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final bool centerTitle;
  final bool isScrollable;

  const CustomAppBar({
    super.key,
    this.title = '',
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
    this.centerTitle = true,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppBar(
      primary: !isScrollable,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      titleSpacing: centerTitle ? null : AppSpacing.pageX.w,
      leading: leading ??
          (showBackButton && context.canPop()
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18.sp,
                    color: p.ink,
                  ),
                  onPressed: () => context.pop(),
                )
              : null),
      title: Text(
        title,
        style: AppTypography.tagline.copyWith(color: p.ink),
      ),
      actions: actions != null
          ? [...actions!, SizedBox(width: AppSpacing.xs.w)]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
