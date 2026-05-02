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

class RegisterPage extends StatelessWidget {
  final String? returnTo;

  const RegisterPage({super.key, this.returnTo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Daftar',
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
                  Icons.person_add_alt_rounded,
                  color: AppColors.primary,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              Center(
                child: Text(
                  'Mulai perjalananmu',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
                  child: Text(
                    'Buat akun untuk mencatat emosi harian\ndan memahami siklusmu dengan lebih baik.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl.h),
              SizedBox(
                width: double.infinity,
                child: Form(
                  child: Column(
                    children: [
                      const CustomTextField(
                        label: 'Nama Lengkap',
                        hintText: 'Evelyn Thorne',
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      const CustomTextField(
                        label: 'Email',
                        hintText: 'nama@contoh.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      const CustomTextField(
                        label: 'Kata Sandi',
                        hintText: '••••••••',
                        isPassword: true,
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      PrimaryButton(
                        text: 'Buat Akun',
                        onPressed: () {
                          if (returnTo != null && returnTo!.isNotEmpty) {
                            context.goNamed(returnTo!);
                          } else {
                            context.goNamed(RouteNames.home);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
              Center(
                child: AuthFooterPrompt(
                  text: 'Sudah punya akun? ',
                  linkText: 'Masuk',
                  onTap: () {
                    context.goNamed(RouteNames.login);
                  },
                ),
              ),
              SizedBox(height: AppSpacing.xl.h),
              // Teks: Terms & Conditions
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
                  child: Text(
                    'Dengan mendaftar, kamu setuju dengan Kebijakan Privasi dan Syarat Perawatan kami.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary.withAlpha(140),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),
            ],
          ),
        ),
      ),
    );
  }
}
