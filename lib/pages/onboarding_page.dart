import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg.w,
                    vertical: AppSpacing.lg.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: AppSpacing.md.h),
                      Column(
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/logo.png',
                              width: 160.w,
                              height: 160.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: AppSpacing.lg.h),
                          Text(
                            'Selamat datang di FemMonitor',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          SizedBox(height: AppSpacing.sm.h),
                          Text(
                            'Pilih cara masuk untuk mulai memantau emosi dan siklusmu.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            PrimaryButton(
                              text: 'Daftar',
                              onPressed: () {
                                context.goNamed(RouteNames.register);
                              },
                            ),
                            SizedBox(height: AppSpacing.sm.h),
                            SizedBox(
                              width: double.infinity,
                              height: 56.h,
                              child: OutlinedButton(
                                onPressed: () {
                                  context.goNamed(RouteNames.login);
                                },
                                child: Text(
                                  'Masuk',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.sm.h),
                            TextButton(
                              onPressed: () {
                                context.goNamed(RouteNames.initialQuestions);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                              ),
                              child: Text(
                                'Lanjut sebagai tamu',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
