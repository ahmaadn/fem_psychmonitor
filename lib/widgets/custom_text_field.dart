import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Input & Trailing Label (Row)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            // Tampilkan trailingLabel jika ada
            if (widget.trailingLabel != null) widget.trailingLabel!,
          ],
        ),
        SizedBox(height: 8.h),
        // Kotak Input
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary.withAlpha(140),
            ),
            filled: true,
            fillColor: AppColors.inputFill,

            // Menampilkan prefix icon hanya jika ada isinya
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: AppColors.textSecondary.withAlpha(160),
                    size: 20.sp,
                  )
                : null,

            // Menampilkan suffix icon (mata) khusus form password
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary.withAlpha(140),
                      size: 22.sp,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,

            // Border normal
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            // Border saat focused
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            // Border saat ada error
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.warning, width: 1.5),
            ),
            // Border saat focused & ada error
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.warning, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: AppSpacing.md.h,
              horizontal: AppSpacing.md.w,
            ),
            errorStyle: TextStyle(
              color: AppColors.warning,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
