import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
    final p = context.palette;
    return RichText(
      text: TextSpan(
        text: text,
        style: AppTypography.caption.copyWith(color: p.textSecondary),
        children: [
          TextSpan(
            text: linkText,
            style: AppTypography.bodyStrong.copyWith(color: p.primaryText),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
    );
  }
}
