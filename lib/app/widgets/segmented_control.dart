import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Tonal segmented control — track surface-2, selected primary-100 / primary-800.
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.values,
    required this.selected,
    required this.onChanged,
    required this.labelOf,
  });

  final List<T> values;
  final T selected;
  final ValueChanged<T> onChanged;
  final String Function(T) labelOf;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      padding: EdgeInsets.all(AppSpacing.xxs.r),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(AppRadius.md.r),
      ),
      child: Row(
        children: values.map((v) {
          final isSelected = v == selected;
          final bg = isSelected
              ? (p.isDark ? p.primarySoft : AppColors.primary100)
              : Colors.transparent;
          final fg = isSelected ? p.primaryText : p.textSecondary;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xs.h),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppRadius.sm.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  labelOf(v),
                  style: AppTypography.label.copyWith(
                    color: fg,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
