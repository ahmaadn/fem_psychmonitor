import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/segmented_control.dart';
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
        decoration: BoxDecoration(color: p.canvas),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageX.w,
                    vertical: AppSpacing.xl.h,
                  ),
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
                                color: p.textSecondary,
                                size: 22.sp,
                              ),
                            )
                          else
                            SizedBox(width: 48.w),
                          SizedBox(
                            width: 120.w,
                            child: AppSegmentedControl<bool>(
                              values: const [false, true],
                              selected: isEnglish,
                              onChanged: (en) {
                                if (en) {
                                  context
                                      .read<LocaleProvider>()
                                      .switchToEnglish();
                                } else {
                                  context
                                      .read<LocaleProvider>()
                                      .switchToIndonesian();
                                }
                              },
                              labelOf: (en) => en ? 'EN' : 'ID',
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const VoiceprintOrb(
                            mode: VoiceprintMode.idle,
                            size: 200,
                          ),
                          SizedBox(height: AppSpacing.xxl.h - 4.h),
                          Text(
                            l10n.welcomeToApp,
                            textAlign: TextAlign.center,
                            style: AppTypography.display.copyWith(
                              color: p.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs.h),
                          SizedBox(
                            width: 280.w,
                            child: Text(
                              l10n.chooseSignInMethod,
                              textAlign: TextAlign.center,
                              style: AppTypography.body.copyWith(
                                color: p.textSecondary,
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
                              SizedBox(height: AppSpacing.sm.h),
                              SecondaryButton(
                                text: l10n.signIn,
                                onPressed: () =>
                                    context.goNamed(RouteNames.login),
                              ),
                            ] else ...[
                              SizedBox(height: AppSpacing.sm.h),
                              SecondaryButton(
                                text: l10n.back,
                                icon: Icons.arrow_back_rounded,
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.goNamed(RouteNames.profile);
                                  }
                                },
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
