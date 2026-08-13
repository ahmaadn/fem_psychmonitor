import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Drag handle for bottom sheets (DESIGN.md sheet convention).
class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Container(
        width: AppSpacing.sheetHandleW.w,
        height: AppSpacing.xxs.h,
        decoration: BoxDecoration(
          color: p.divider,
          borderRadius: AppRadius.chip,
        ),
      ),
    );
  }
}

/// Surface shell for modal bottom sheets — surface-1 + xl top radius.
class AppBottomSheetShell extends StatelessWidget {
  const AppBottomSheetShell({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface1,
        borderRadius: AppRadius.sheet,
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Shows a themed bottom sheet with transparent scrim and xl top corners.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    backgroundColor: Colors.transparent,
    builder: (ctx) => AppBottomSheetShell(child: builder(ctx)),
  );
}
