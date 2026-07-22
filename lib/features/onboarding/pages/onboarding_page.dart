import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/voiceprint_orb.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
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
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final isEnglish = localeProvider.isEnglish;

    return Scaffold(
      backgroundColor: p.canvas,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: p.canvasGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
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
                                color: p.inkMuted,
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
                            style: AppTypography.displayMd.copyWith(
                              fontSize: 30.0,
                              color: p.ink,
                            ),
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
                                color: p.inkMuted,
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
                              onPressed: () {
                                context
                                    .read<QuestionnaireViewModel>()
                                    .resetAssessmentProgress();
                                if (fromProfile) {
                                  context.pushNamed(RouteNames.oceanTest);
                                } else {
                                  context.goNamed(RouteNames.oceanTest);
                                }
                              },
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
                                      color: p.primary,
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
                                    color: p.primary,
                                    size: 18.sp,
                                  ),
                                  label: Text(
                                    l10n.back,
                                    style: TextStyle(
                                      color: p.primary,
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
      ),
    );
  }
}

class _LangTabs extends StatelessWidget {
  final bool isEnglish;
  const _LangTabs({this.isEnglish = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.chip,
        border: Border.all(color: p.primary.withValues(alpha: 0.2)),
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
    final p = ctx.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: active ? p.primary : Colors.transparent,
          borderRadius: AppRadius.chip,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: active
                ? p.onPrimary
                : p.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
