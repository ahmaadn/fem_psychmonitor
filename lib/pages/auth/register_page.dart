import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/widgets/auth_footer_prompt.dart';
import 'package:fem_psychmonitor/widgets/custom_text_field.dart';
import 'package:fem_psychmonitor/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 48.h),

              Center(
                child: Text(
                  'Create Your Account',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'Begin your journey toward emotional clarity\nand mental well-being.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15.sp,
                      color: AppColors.onSurface.withAlpha(153),
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 48.h),

              Form(
                child: Column(
                  children: [
                    const CustomTextField(
                      label: 'Full Name',
                      hintText: 'Evelyn Thorne',
                      // Tidak pakai prefixIcon sesuai gambar
                    ),

                    SizedBox(height: 24.h),

                    const CustomTextField(
                      label: 'Email',
                      hintText: 'hello@sanctuary.com',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    SizedBox(height: 24.h),

                    const CustomTextField(
                      label: 'Password',
                      hintText: '••••••••',
                      isPassword: true,
                    ),

                    SizedBox(height: 40.h),

                    PrimaryButton(text: 'Register', onPressed: () {}),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              Center(
                child: AuthFooterPrompt(
                  text: 'Already have an account? ',
                  linkText: 'Log In',
                  onTap: () {
                    context.goNamed('login');
                  },
                ),
              ),

              SizedBox(height: 48.h),

              // Teks: Terms & Conditions
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'By registering, you agree to our Privacy Sanctuary Policy and Terms of Care.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: AppColors.onSurface.withAlpha(102),
                      height: 1.5,
                    ),
                  ),
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
