import 'package:fem_psychmonitor/app/config/app_colors.dart';
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
    this.title = 'FEM-PSYCHMONITOR',
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
    this.centerTitle = true,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Jika masuk ke dalam area scroll (yang sudah punya SafeArea), matikan primary padding
      // agar tidak terjadi double padding di bagian atas layar.
      primary: !isScrollable,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      titleSpacing: centerTitle ? null : 24.w,
      leading:
          leading ??
          (showBackButton && context.canPop()
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.primary.withAlpha(127),
                  ),
                  onPressed: () {
                    context.pop();
                  },
                )
              : null),
      title: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: AppColors.primary,
        ),
      ),

      actions: actions != null ? [...actions!, SizedBox(width: 8.w)] : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
