import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_emoji.dart';
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

  /// Map a 0–100 mental-health score to the emotion that represents the
  /// hero avatar. Higher = happier; lower = sadder; middle = neutral.
  EmotionLabelType _emotionForScore(int score) {
    if (score <= 30) return EmotionLabelType.sad;
    if (score <= 60) return EmotionLabelType.neutral;
    return EmotionLabelType.happy;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = context.watch<LocaleProvider>().isEnglish;

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
            builder: (context, viewModel, _) {
              final score = (viewModel.psychScore ?? 0).clamp(0, 100);
              final psychClass = viewModel.psychClass;
              final emotion = _emotionForScore(score);

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageX.w,
                  AppSpacing.md.h,
                  AppSpacing.pageX.w,
                  AppSpacing.xxl.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Hero: avatar + score + scale ────────────────────
                    _ScoreHero(
                      score: score,
                      emotion: emotion,
                      p: p,
                      scoreLabel: l10n.yourScore,
                    ),
                    SizedBox(height: AppSpacing.xl.h),

                    // ── Class badge + description ─────────────────────
                    if (psychClass != null) ...[
                      _ClassBadge(
                        label: psychClass.className.get(isEnglish),
                        p: p,
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      Text(
                        psychClass.description.get(isEnglish),
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          fontSize: 15.sp,
                          height: 1.55,
                          color: p.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl.h),

                      // ── Recommendation card ────────────────────────
                      _RecommendationCard(
                        text: psychClass.recommendation.get(isEnglish),
                        isEnglish: isEnglish,
                        p: p,
                      ),
                    ],

                    SizedBox(height: AppSpacing.xxl.h + 4.h),

                    // ── CTA: next step ─────────────────────────────────
                    Text(
                      l10n.tryVoiceTestQuestion,
                      textAlign: TextAlign.center,
                      style: AppTypography.title.copyWith(
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
                      textColor: p.primaryText,
                      borderColor: p.primary,
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

// ── Hero block: large emotion avatar + score + 0–100 scale ─────────────
class _ScoreHero extends StatelessWidget {
  const _ScoreHero({
    required this.score,
    required this.emotion,
    required this.p,
    required this.scoreLabel,
  });

  final int score;
  final EmotionLabelType emotion;
  final AppPalette p;
  final String scoreLabel;

  @override
  Widget build(BuildContext context) {
    final emotionBase = p.emotionBase(emotion);
    final progress = (score / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        AppSpacing.xl.h,
        AppSpacing.lg.w,
        AppSpacing.lg.h,
      ),
      decoration: p.panelSoft(radius: AppRadius.xl),
      child: Column(
        children: [
          // Tiny header row with leading icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.psychology_outlined,
                size: 18.sp,
                color: p.primaryText,
              ),
              SizedBox(width: AppSpacing.xxs.w),
              Text(
                scoreLabel.toUpperCase(),
                style: AppTypography.label.copyWith(
                  color: p.primaryText,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Avatar: halo + white circle w/ colored ring + score badge
          SizedBox(
            width: 168.w,
            height: 168.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer halo
                Container(
                  width: 168.w,
                  height: 168.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: emotionBase.withValues(alpha: 0.14),
                  ),
                ),
                // Inner white circle with colored ring
                Container(
                  width: 132.w,
                  height: 132.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.surface1,
                    border: Border.all(
                      color: emotionBase.withValues(alpha: 0.55),
                      width: 3,
                    ),
                    boxShadow: p.cardShadow,
                  ),
                  child: Center(
                    child: EmotionEmoji(asset: emotion.emojiAsset, size: 76),
                  ),
                ),
                // Score badge anchored bottom-center of avatar
                Positioned(
                  bottom: 8.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: p.primaryFill,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      boxShadow: [
                        BoxShadow(
                          color: p.primaryFill.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$score',
                          style: AppTypography.display.copyWith(
                            fontSize: 28.sp,
                            color: p.onPrimaryFill,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          '/ 100',
                          style: AppTypography.caption.copyWith(
                            color: p.onPrimaryFill.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.lg.h),

          // 0–100 scale with marker
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, c) {
                    final trackW = c.maxWidth;
                    // Align(progress*2-1, 0) maps 0..1 -> -1..1 across the bar
                    return SizedBox(
                      height: 24.h,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Track
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 8.h,
                            child: Container(
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: p.surface3,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                            ),
                          ),
                          // Fill
                          Positioned(
                            left: 0,
                            top: 8.h,
                            child: Container(
                              height: 8.h,
                              width: trackW * progress,
                              decoration: BoxDecoration(
                                color: p.primaryFill,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                            ),
                          ),
                          // Marker
                          Positioned(
                            left:
                                (trackW * progress).clamp(0.0, trackW) - 10.w,
                            top: 0,
                            child: Container(
                              width: 20.w,
                              height: 20.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: p.primaryFill,
                                border: Border.all(
                                  color: p.surface1,
                                  width: 3,
                                ),
                                boxShadow: p.cardShadow,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: AppSpacing.xs.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ScaleTick(label: '0', p: p),
                      _ScaleTick(label: '25', p: p),
                      _ScaleTick(label: '50', p: p),
                      _ScaleTick(label: '75', p: p),
                      _ScaleTick(label: '100', p: p),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaleTick extends StatelessWidget {
  const _ScaleTick({required this.label, required this.p});
  final String label;
  final AppPalette p;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.caption.copyWith(color: p.textTertiary),
    );
  }
}

// ── Class badge ────────────────────────────────────────────────────────
class _ClassBadge extends StatelessWidget {
  const _ClassBadge({required this.label, required this.p});
  final String label;
  final AppPalette p;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg.w,
          vertical: AppSpacing.xs.h + 2.h,
        ),
        decoration: BoxDecoration(
          color: p.secondaryFill,
          borderRadius: AppRadius.button,
          boxShadow: [
            BoxShadow(
              color: p.secondaryFill.withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_rounded,
              size: 18.sp,
              color: p.onSecondary,
            ),
            SizedBox(width: AppSpacing.xxs.w + 2.w),
            Text(
              label,
              style: AppTypography.bodyStrong.copyWith(
                color: p.onSecondary,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recommendation card ────────────────────────────────────────────────
class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.text,
    required this.isEnglish,
    required this.p,
  });

  final String text;
  final bool isEnglish;
  final AppPalette p;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: p.card(radius: AppRadius.lg, elevated: true),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: p.primaryWash,
              borderRadius: BorderRadius.circular(AppRadius.md.r),
              border: Border.all(
                color: p.primaryFill.withValues(alpha: 0.18),
                width: AppBorder.thin,
              ),
            ),
            child: Icon(
              Icons.tips_and_updates_outlined,
              color: p.primaryText,
              size: 22.sp,
            ),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnglish ? 'Recommendation' : 'Rekomendasi',
                  style: AppTypography.label.copyWith(
                    color: p.textTertiary,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs.h + 2.h),
                Text(
                  text,
                  style: AppTypography.body.copyWith(
                    fontSize: 15.sp,
                    height: 1.55,
                    color: p.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}