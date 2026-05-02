import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthFooterPrompt extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onTap;

  const AuthFooterPrompt({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
        ),
        children: [
          TextSpan(
            text: linkText,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 12.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
    );
  }
}
