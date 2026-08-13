import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Input — surface-2, 12dp radius, divider border, primary-500 focus.
class AppTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? trailingLabel;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.trailingLabel,
    this.controller,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: AppTypography.label.copyWith(color: p.textSecondary),
              ),
              if (widget.trailingLabel != null) widget.trailingLabel!,
            ],
          ),
        if (widget.label.isNotEmpty) SizedBox(height: AppSpacing.xs.h),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          style: AppTypography.body.copyWith(color: p.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle:
                AppTypography.body.copyWith(color: p.textTertiary),
            filled: true,
            fillColor: p.surface2,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: p.textTertiary, size: 20.sp)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: p.textTertiary,
                      size: 22.sp,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.field,
              borderSide: BorderSide(color: p.divider, width: AppBorder.thin),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.field,
              borderSide: BorderSide(
                color: AppColors.primary500,
                width: AppBorder.medium,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.field,
              borderSide: BorderSide(
                color: p.error,
                width: AppBorder.medium,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.field,
              borderSide: BorderSide(
                color: p.error,
                width: AppBorder.thick,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: AppSpacing.sm.h,
              horizontal: AppSpacing.md.w,
            ),
            errorStyle: AppTypography.caption.copyWith(color: p.errorText),
          ),
        ),
      ],
    );
  }
}

/// Back-compat alias used across auth/profile.
typedef CustomTextField = AppTextField;
