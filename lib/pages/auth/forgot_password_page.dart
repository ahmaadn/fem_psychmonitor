import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/widgets/auth_footer_prompt.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/widgets/custom_text_field.dart';
import 'package:fem_psychmonitor/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        backgroundColor: Colors.transparent,
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 48.h),
              Text(
                'Reset Password',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'Enter your email to receive a reset link',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15.sp,
                  color: AppColors.onSurface.withAlpha(153),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              Form(
                child: Column(
                  children: [
                    const CustomTextField(
                      label: 'EMAIL ADDRESS',
                      hintText: 'name@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 40.h),
                    PrimaryButton(
                      text: 'Send Link',
                      suffixIcon: Icons.arrow_forward_rounded,
                      onPressed: () {
                        context.goNamed(RouteNames.login);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48.h),
              Center(
                child: AuthFooterPrompt(
                  text: "Remember your password? ",
                  linkText: "Login here",
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(RouteNames.login);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
