import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/session_card.dart';
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
          style: AppTypography.subtitle.copyWith(color: p.textPrimary),
        ),
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(color: p.canvas),
        child: SafeArea(
          child: Consumer<QuestionnaireViewModel>(
            builder: (context, viewModel, child) {
              final score = viewModel.psychScore ?? 0;
              final psychClass = viewModel.psychClass;
              final emoji = score <= 25
                  ? '😢'
                  : score <= 50
                  ? '😔'
                  : score <= 75
                  ? '😊'
                  : '🥰';

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageX.w,
                  vertical: AppSpacing.xl.h,
                ),
                child: Column(
                  children: [
                    SessionCard(
                      child: Column(
                        children: [
                          Text(
                            l10n.yourScore.toUpperCase(),
                            style: AppTypography.label.copyWith(
                              color: p.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm.h),
                          Text(emoji, style: AppTypography.emojiXl),
                          SizedBox(height: AppSpacing.xxs.h),
                          Text(
                            '$score / 100',
                            style: AppTypography.metric.copyWith(
                              color: p.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xl.h),
                          if (psychClass != null) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg.w,
                                vertical: AppSpacing.xs.h,
                              ),
                              decoration: BoxDecoration(
                                color: p.secondaryFill.withValues(alpha: 0.14),
                                borderRadius: AppRadius.chip,
                              ),
                              child: Text(
                                psychClass.className.get(isEnglish),
                                style: AppTypography.bodyStrong.copyWith(
                                  color: p.secondaryText,
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.md.h),
                            SizedBox(
                              width: 280.w,
                              child: Text(
                                psychClass.description.get(isEnglish),
                                textAlign: TextAlign.center,
                                style: AppTypography.body.copyWith(
                                  color: p.textSecondary,
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.md.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(AppSpacing.md.w),
                              decoration: BoxDecoration(
                                color: p.surface2,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md.r,
                                ),
                              ),
                              child: Text(
                                l10n.suggestionLabel(
                                  psychClass.recommendation.get(isEnglish),
                                ),
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyStrong.copyWith(
                                  color: p.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxl.h + 4.h),
                    const VoiceprintOrb(mode: VoiceprintMode.idle, size: 160),
                    SizedBox(height: AppSpacing.xxl.h + 4.h),
                    Text(
                      l10n.tryVoiceTestQuestion,
                      textAlign: TextAlign.center,
                      style: AppTypography.subtitle.copyWith(
                        color: p.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg.h),
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
                    SizedBox(height: AppSpacing.sm.h),
                    SecondaryButton(
                      text: l10n.tryVoiceTest,
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
                    ),
                    SizedBox(height: AppSpacing.xl.h),
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
