import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/app_logo.dart';
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
  late final AnimationController _progressController;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) _navigateBasedOnAuth();
          })
          ..forward();
  }

  Future<void> _navigateBasedOnAuth() async {
    if (!mounted || _hasNavigated) return;
    final authVm = context.read<AuthViewModel>();
    await authVm.checkAuth();
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    if (authVm.isAuthenticated) {
      if (authVm.hasCompletedAssessment) {
        context.goNamed(RouteNames.dashboard);
      } else {
        context.goNamed(RouteNames.oceanTest);
      }
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
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: p.canvas,
      body: DecoratedBox(
        decoration: BoxDecoration(color: p.canvas),
        child: GestureDetector(
          onVerticalDragEnd: (d) {
            if ((d.primaryVelocity ?? 0) < 0) _navigateBasedOnAuth();
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 320.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const AppLogo(size: 160),
                        SizedBox(height: 32.h),
                        Text(
                          l10n.appName,
                          textAlign: TextAlign.center,
                          style: AppTypography.display.copyWith(
                            fontSize: 36.0,
                            color: p.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          l10n.appTagline,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: p.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 320.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, _) => SizedBox(
                            width: 220.w,
                            child: ClipRRect(
                              borderRadius: AppRadius.chip,
                              child: LinearProgressIndicator(
                                value: _progressController.value,
                                minHeight: 5.h,
                                backgroundColor: p.surface3,
                                valueColor: AlwaysStoppedAnimation(
                                  p.primaryFill,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: p.textSecondary,
                          size: 22.sp,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          l10n.swipeUpToStart,
                          style: AppTypography.label.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
