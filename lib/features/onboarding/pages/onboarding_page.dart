import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/voiceprint_orb.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OnboardingPage extends StatelessWidget {
  final bool fromProfile;
  const OnboardingPage({super.key, this.fromProfile = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final isEnglish = localeProvider.isEnglish;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (fromProfile)
                          IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.goNamed(RouteNames.profile);
                              }
                            },
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.textSecondary,
                              size: 22.sp,
                            ),
                          )
                        else
                          SizedBox(width: 48.w),
                        _LangTabs(isEnglish: isEnglish),
                      ],
                    ),
                    Column(
                      children: [
                        const VoiceprintOrb(
                          mode: VoiceprintMode.idle,
                          size: 200,
                        ),
                        SizedBox(height: 28.h),
                        Text(
                          l10n.welcomeToApp,
                          textAlign: TextAlign.center,
                          style: AppTypography.fraunces(size: 30),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          width: 280.w,
                          child: Text(
                            l10n.chooseSignInMethod,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              height: 1.55,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          PrimaryButton(
                            text: l10n.mulai,
                            onPressed: () => fromProfile
                                ? context.pushNamed(RouteNames.mbtiSelection)
                                : context.goNamed(RouteNames.mbtiSelection),
                          ),
                          if (!fromProfile) ...[
                            SizedBox(height: 12.h),
                            SizedBox(
                              width: double.infinity,
                              height: 52.h,
                              child: OutlinedButton(
                                onPressed: () =>
                                    context.goNamed(RouteNames.login),
                                child: Text(
                                  l10n.signIn,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            SizedBox(height: 12.h),
                            SizedBox(
                              width: double.infinity,
                              height: 52.h,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.goNamed(RouteNames.profile);
                                  }
                                },
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                  color: AppColors.primary,
                                  size: 18.sp,
                                ),
                                label: Text(
                                  l10n.back,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LangTabs extends StatelessWidget {
  final bool isEnglish;
  const _LangTabs({this.isEnglish = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(9999.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tab(
            context,
            'ID',
            !isEnglish,
            () => context.read<LocaleProvider>().switchToIndonesian(),
          ),
          _tab(
            context,
            'EN',
            isEnglish,
            () => context.read<LocaleProvider>().switchToEnglish(),
          ),
        ],
      ),
    );
  }

  Widget _tab(BuildContext ctx, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9999.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: active
                ? Colors.white
                : AppColors.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
