import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isLoading;
  final bool isDisabled;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final disabled = widget.isDisabled || widget.isLoading;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onPressed();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: double.infinity,
          height: AppSpacing.touch.h,
          alignment: Alignment.center,
          decoration: p.pillFill(disabled ? p.strawberry : p.primary),
          child: widget.isLoading
              ? SizedBox(
                  height: 22.h,
                  width: 22.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(p.onPrimary),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.prefixIcon != null) ...[
                      Icon(widget.prefixIcon, size: 18.sp, color: p.onPrimary),
                      SizedBox(width: AppSpacing.xs.w),
                    ],
                    Text(
                      widget.text,
                      style: AppTypography.body.copyWith(
                        color: disabled ? p.inkFaint : p.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.suffixIcon != null) ...[
                      SizedBox(width: AppSpacing.xs.w),
                      Icon(widget.suffixIcon, size: 18.sp, color: p.onPrimary),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatefulWidget {
  final String text;
  final String? subText;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const SecondaryButton({
    super.key,
    required this.text,
    this.subText,
    this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = widget.textColor ?? p.primary;
    final border = widget.borderColor ?? p.primary;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: AppSpacing.touch.h),
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.buttonY.h,
            horizontal: AppSpacing.buttonX.w,
          ),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? p.surface,
            borderRadius: AppRadius.button,
            border: Border.all(color: border, width: AppBorder.thin),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: fg, size: 18.sp),
                SizedBox(width: AppSpacing.xs.w),
              ],
              Flexible(
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.subText != null) ...[
                SizedBox(width: AppSpacing.xs.w),
                Text(
                  widget.subText!,
                  style: AppTypography.caption
                      .copyWith(color: fg.withValues(alpha: 0.6)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Matcha filled pill — secondary brand action.
class MatchaButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? prefixIcon;
  final bool isLoading;
  final bool isDisabled;

  const MatchaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.prefixIcon,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  State<MatchaButton> createState() => _MatchaButtonState();
}

class _MatchaButtonState extends State<MatchaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final disabled = widget.isDisabled || widget.isLoading;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onPressed();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: double.infinity,
          height: AppSpacing.touch.h,
          alignment: Alignment.center,
          decoration: p.pillFill(disabled ? p.matchaSoft : p.secondary),
          child: widget.isLoading
              ? SizedBox(
                  height: 22.h,
                  width: 22.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(p.onSecondary),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.prefixIcon != null) ...[
                      Icon(widget.prefixIcon,
                          size: 18.sp, color: p.onSecondary),
                      SizedBox(width: AppSpacing.xs.w),
                    ],
                    Text(
                      widget.text,
                      style: AppTypography.body.copyWith(
                        color: disabled ? p.inkFaint : p.onSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
