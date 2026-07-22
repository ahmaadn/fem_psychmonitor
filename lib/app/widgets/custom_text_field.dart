import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? trailingLabel;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.trailingLabel,
    this.controller,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: AppTypography.captionStrong.copyWith(color: p.inkMuted),
            ),
            if (widget.trailingLabel != null) widget.trailingLabel!,
          ],
        ),
        SizedBox(height: AppSpacing.xs.h),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          style: AppTypography.body.copyWith(color: p.ink),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTypography.caption.copyWith(color: p.inkFaint),
            filled: true,
            fillColor: p.inputFill,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: p.inkFaint, size: 20.sp)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: p.inkFaint,
                      size: 22.sp,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.field,
              borderSide: p.hairlineSide,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.field,
              borderSide: p.focusSide,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.field,
              borderSide: BorderSide(
                color: p.primaryFocus,
                width: AppBorder.medium,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.field,
              borderSide: BorderSide(
                color: p.primaryFocus,
                width: AppBorder.thick,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: AppSpacing.sm.h,
              horizontal: AppSpacing.md.w,
            ),
            errorStyle:
                AppTypography.finePrint.copyWith(color: p.primaryFocus),
          ),
        ),
      ],
    );
  }
}
