import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/widgets/auth_footer_prompt.dart';
import 'package:fem_psychmonitor/widgets/custom_text_field.dart';
import 'package:fem_psychmonitor/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        // centerTitle: false,
        elevation: 0,
        title: Text(
          'FEM-PSYCHMONITOR',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 48.h),

              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),

              SizedBox(height: 12.h),

              Text(
                'Continue your journey to well-being.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15.sp,
                  color: AppColors.onSurface.withAlpha(153),
                  height: 1.5,
                ),
              ),

              SizedBox(height: 48.h),

              Form(
                child: Column(
                  children: [
                    const CustomTextField(
                      label: 'Email Address',
                      hintText: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    SizedBox(height: 24.h),

                    CustomTextField(
                      label: 'Password',
                      hintText: '••••••••',
                      isPassword: true,
                      trailingLabel: GestureDetector(
                        onTap: () {
                          context.goNamed('forgot-password');
                        },
                        child: Text(
                          'Forgot Password?',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    PrimaryButton(text: 'Login', onPressed: () {}),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              Center(
                child: AuthFooterPrompt(
                  text: 'Don\'t have an account? ',
                  linkText: 'Sign Up',
                  onTap: () {
                    context.goNamed('register');
                  },
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
