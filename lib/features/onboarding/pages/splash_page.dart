import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  // AnimationController untuk mengontrol progress bar dan navigasi otomatis
  late final AnimationController _progressController;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _navigateBasedOnAuth();
            }
          })
          ..forward();
  }

  /// Check auth state and navigate accordingly:
  /// - Authenticated → Home
  /// - Not authenticated → Onboarding
  Future<void> _navigateBasedOnAuth() async {
    if (!mounted || _hasNavigated) return;

    final authVm = context.read<AuthViewModel>();
    await authVm.checkAuth();

    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    if (authVm.isAuthenticated) {
      context.goNamed(RouteNames.home);
    } else {
      context.goNamed(RouteNames.onboarding);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      // Menggunakan GestureDetector untuk menangkap aksi "Swipe Up"
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          // Jika primaryVelocity bernilai negatif, artinya pengguna menggeser ke atas
          if ((details.primaryVelocity ?? 0) < 0) {
            _navigateBasedOnAuth();
          }
        },
        child: SafeArea(
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
                              l10n.appName,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            SizedBox(height: AppSpacing.sm.h),
                            Text(
                              l10n.appTagline,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: AppSpacing.lg.h),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md.h,
                              horizontal: AppSpacing.lg.w,
                            ),
                            child: Column(
                              children: [
                                AnimatedBuilder(
                                  animation: _progressController,
                                  builder: (context, child) {
                                    final progress = _progressController.value;

                                    return SizedBox(
                                      width: 220.w,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.full,
                                        ),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 6.h,
                                          backgroundColor:
                                              AppColors.surfaceContainerLow,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.primary,
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: AppSpacing.sm.h),
                                Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  color: AppColors.textSecondary,
                                  size: 24.sp,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  l10n.swipeUpToStart,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        letterSpacing: 0.5,
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}
