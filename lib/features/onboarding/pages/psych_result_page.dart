import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/voiceprint_orb.dart';
import 'package:fem_psychmonitor/features/onboarding/utils/onboarding_result_persistence.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PsychResultPage extends StatefulWidget {
  const PsychResultPage({super.key});

  @override
  State<PsychResultPage> createState() => _PsychResultPageState();
}

class _PsychResultPageState extends State<PsychResultPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveOnboardingResults();
    });
  }

  Future<void> _saveOnboardingResults() async {
    final authVm = context.read<AuthViewModel>();
    if (authVm.currentUser != null) {
      await savePendingOnboardingResults(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final isEnglish = localeProvider.isEnglish;

    return Scaffold(
      backgroundColor: p.canvas,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.mentalHealthResultTitle,
          style: AppTypography.bodyStrong.copyWith(
            fontSize: 18.0,
            color: p.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: p.canvasGradient),
        child: SafeArea(
          child: Consumer<QuestionnaireViewModel>(
            builder: (context, viewModel, child) {
              final score = viewModel.psychScore ?? 0;
              final psychClass = viewModel.psychClass;

              return SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: p.hairline),
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.yourScore,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: p.inkMuted,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            score <= 25
                                ? '😢'
                                : score <= 50
                                    ? '😔'
                                    : score <= 75
                                        ? '😊'
                                        : '🥰',
                            style: TextStyle(fontSize: 36.sp, height: 1.1),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$score / 100',
                            style: AppTypography.heroDisplay.copyWith(
                              color: p.ink,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          if (psychClass != null) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: p.secondary.withValues(
                                  alpha: 0.16,
                                ),
                                borderRadius: AppRadius.chip,
                              ),
                              child: Text(
                                psychClass.className.get(isEnglish),
                                style: TextStyle(
                                  color: p.secondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            SizedBox(
                              width: 280.w,
                              child: Text(
                                psychClass.description.get(isEnglish),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  height: 1.55,
                                  color: p.inkMuted,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: p.strawberrySoft,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              child: Text(
                                l10n.suggestionLabel(
                                  psychClass.recommendation.get(isEnglish),
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: p.ink,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 36.h),
                    const VoiceprintOrb(mode: VoiceprintMode.idle, size: 160),
                    SizedBox(height: 36.h),
                    Text(
                      l10n.tryVoiceTestQuestion,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyStrong.copyWith(
                        fontSize: 18.0,
                        color: p.ink,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    PrimaryButton(
                      text: l10n.goToDashboard,
                      onPressed: () async {
                        final authVm = context.read<AuthViewModel>();
                        if (!authVm.isAuthenticated) {
                          context.goNamed(RouteNames.postAssessmentChoice);
                          return;
                        }
                        await savePendingOnboardingResults(context);
                        if (!context.mounted) return;
                        context.goNamed(RouteNames.dashboard);
                      },
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: OutlinedButton(
                        onPressed: () async {
                          final authVm = context.read<AuthViewModel>();
                          if (!authVm.isAuthenticated) {
                            context.goNamed(RouteNames.postAssessmentChoice);
                            return;
                          }
                          await savePendingOnboardingResults(context);
                          if (!context.mounted) return;
                          context.goNamed(RouteNames.liveRecording);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: p.hairline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(
                          l10n.tryVoiceTest,
                          style: TextStyle(
                            color: p.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
