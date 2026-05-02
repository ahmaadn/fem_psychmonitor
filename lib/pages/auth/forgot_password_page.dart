import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/widgets/auth_footer_prompt.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/widgets/custom_text_field.dart';
import 'package:fem_psychmonitor/widgets/button_widget.dart';
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
        title: 'Lupa Kata Sandi',
        backgroundColor: Colors.transparent,
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: AppSpacing.xl.h),
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outline),
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.primary,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              Text(
                'Atur ulang kata sandi',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm.h),
              Text(
                'Masukkan email untuk menerima tautan pemulihan.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl.h),
              SizedBox(
                width: double.infinity,
                child: Form(
                  child: Column(
                    children: [
                      const CustomTextField(
                        label: 'Email',
                        hintText: 'nama@contoh.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      PrimaryButton(
                        text: 'Kirim tautan',
                        suffixIcon: Icons.arrow_forward_rounded,
                        onPressed: () {
                          context.goNamed(RouteNames.login);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl.h),
              Center(
                child: AuthFooterPrompt(
                  text: 'Ingat kata sandi? ',
                  linkText: 'Masuk di sini',
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
