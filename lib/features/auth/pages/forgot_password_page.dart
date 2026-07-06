import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/voiceprint_orb.dart';
import 'package:fem_psychmonitor/features/auth/widgets/auth_footer_prompt.dart';
import 'package:fem_psychmonitor/app/widgets/custom_text_field.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textSecondary,
            size: 22.sp,
          ),
          onPressed: () => _goBack(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8.h),
              const VoiceprintOrb(mode: VoiceprintMode.idle, size: 140),
              SizedBox(height: 24.h),
              Text(
                l10n.resetPassword,
                textAlign: TextAlign.center,
                style: AppTypography.fraunces(size: 28),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: 280.w,
                child: Text(
                  l10n.enterEmailForRecovery,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 28.h),
              CustomTextField(
                label: l10n.email,
                hintText: l10n.emailHint,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 24.h),
              PrimaryButton(
                text: l10n.sendLink,
                suffixIcon: Icons.arrow_forward_rounded,
                onPressed: () => context.goNamed(RouteNames.login),
              ),
              SizedBox(height: 24.h),
              Center(
                child: AuthFooterPrompt(
                  text: l10n.rememberPassword,
                  linkText: l10n.signInHere,
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(RouteNames.login);
                    }
                  },
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
