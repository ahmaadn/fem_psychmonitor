import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/viewmodels/detection_viewmodel.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/app/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/features/history/widgets/timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class AnalysisResultPage extends StatelessWidget {
  final bool isTeaser;
  const AnalysisResultPage({super.key, this.isTeaser = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detector = context.watch<EmotionDetector>();
    final detectionVm = context.watch<DetectionViewModel>();

    final session = isTeaser ? null : detectionVm.currentSession;

    final timeline = session?.results ?? detector.timeline;
    final dominant =
        session?.dominantEmotion ??
        detector.latest?.label ??
        EmotionLabelType.neutral;
    final dominantConfidence =
        session?.dominantConfidence ?? detector.latest?.confidence ?? 0.0;
    final summaryText = session != null
        ? l10n.resultSummaryDefault
        : (detector.error ?? l10n.resultSummaryDefault);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: l10n.history,
        showBackButton: false,
        isScrollable: false,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.relaxed.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpacing.base.h),
              _buildHeroBanner(
                context,
                l10n,
                dominant: dominant,
                confidence: dominantConfidence,
                summaryText: summaryText,
              ),
              SizedBox(height: AppSpacing.extraSpacious.h),
              _buildSectionCard(
                child: RecordingTimeline(
                  timeline: timeline as List<EmotionResult>,
                ),
              ),
              SizedBox(height: AppSpacing.relaxed.h),
              ComponentTimeline(
                timeline: timeline,
                title: l10n.emotionComponent,
              ),
              SizedBox(height: AppSpacing.relaxed.h),
              PrimaryButton(
                text: l10n.backToDashboard,
                prefixIcon: Icons.dashboard_customize_rounded,
                onPressed: () => context.goNamed(RouteNames.home),
              ),
              SizedBox(height: AppSpacing.base.h),
              SecondaryButton(
                text: l10n.retakeRecording,
                subText: l10n.retakeRecordingSub,
                icon: Icons.replay_rounded,
                onPressed: () => context.goNamed(RouteNames.liveRecording),
              ),
              if (isTeaser) ...[
                SizedBox(height: AppSpacing.relaxed.h),
                _buildTeaserCard(context, l10n),
              ],
              if (!isTeaser) ...[
                SizedBox(height: AppSpacing.relaxed.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.base.w),
                  child: Text(
                    l10n.disclaimer,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.extraSpacious.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    AppLocalizations l10n, {
    required EmotionLabelType dominant,
    required double confidence,
    required String summaryText,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.relaxed.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.analysisResult,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.onPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            l10n.resultSummaryDesc,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              color: AppColors.textPrimaryInverse.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpacing.relaxed.h),
          Center(
            child: CircularPercentIndicator(
              radius: 72.w,
              lineWidth: 10.w,
              percent: confidence.clamp(0.0, 1.0),
              animation: true,
              animationDuration: 1200,
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: AppColors.surface.withValues(alpha: 0.2),
              progressColor: AppColors.secondary,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(confidence * 100).round()}%',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryInverse,
                      letterSpacing: -1.0,
                    ),
                  ),
                  Text(
                    l10n.confidence,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryInverse.withValues(
                        alpha: 0.7,
                      ),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.base.h),
          Text(
            l10n.dominantEmotionLabel(dominant.displayName),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryInverse,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            summaryText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13.sp,
              color: AppColors.textPrimaryInverse.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.relaxed.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outline),
      ),
      child: child,
    );
  }

  Widget _buildTeaserCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.relaxed.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.wantFullResults,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            l10n.loginRegisterForFull,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpacing.base.h),
          SecondaryButton(
            text: l10n.loginRegister,
            icon: Icons.lock_rounded,
            backgroundColor: AppColors.secondaryFixed,
            textColor: AppColors.onSecondaryFixed,
            onPressed: () => context.goNamed(
              RouteNames.login,
              extra: RouteNames.analysisResult,
            ),
          ),
        ],
      ),
    );
  }
}
