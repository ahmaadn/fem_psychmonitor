import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/widgets/button_widget.dart';
import 'package:fem_psychmonitor/widgets/timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class AnalysisResultPage extends StatelessWidget {
  final bool isTeaser;

  const AnalysisResultPage({super.key, this.isTeaser = false});

  @override
  Widget build(BuildContext context) {
    final detector = context.watch<EmotionDetector>();
    final timeline = detector.timeline;

    final dominant = detector.latest?.label ?? EmotionLabelType.neutral;
    final dominantConfidence = detector.latest?.confidence ?? 0.0;
    final summaryText =
        detector.error ??
        'Ringkasan dibuat dari timeline deteksi rekaman Anda.';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'HISTORY', // Kosongkan title tengah
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
                dominant: dominant,
                confidence: dominantConfidence,
                summaryText: summaryText,
              ),
              SizedBox(height: AppSpacing.extraSpacious.h),
              _buildSectionCard(child: RecordingTimeline(timeline: timeline)),
              SizedBox(height: AppSpacing.relaxed.h),
              ComponentTimeline(timeline: timeline, title: 'Komponen Emosi'),
              SizedBox(height: AppSpacing.relaxed.h),
              PrimaryButton(
                text: 'Back to Dashboard',
                prefixIcon: Icons.dashboard_customize_rounded,
                onPressed: () {
                  context.goNamed(RouteNames.home);
                },
              ),
              SizedBox(height: AppSpacing.base.h),
              SecondaryButton(
                text: 'Retake Recording',
                subText: '(Ulangi Rekaman)',
                icon: Icons.replay_rounded,
                onPressed: () {
                  context.goNamed(RouteNames.liveRecording);
                },
              ),
              if (isTeaser) ...[
                SizedBox(height: AppSpacing.relaxed.h),
                _buildTeaserCard(context),
              ],
              if (!isTeaser) ...[
                SizedBox(height: AppSpacing.relaxed.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.base.w),
                  child: Text(
                    '*Perhatian: Hasil analisis ini bersifat indikatif dan tidak menggantikan penilaian profesional.',
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
    BuildContext context, {
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
            'Analysis Result',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.onPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            'Ringkasan hasil analisis rekaman terbaru Anda.',
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
                    'Confidence',
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
            'Emosi Dominan ${dominant.displayName}',
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

  Widget _buildTeaserCard(BuildContext context) {
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
            'Ingin melihat hasil lengkap?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            'Login / Register untuk melihat penuh.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpacing.base.h),
          SecondaryButton(
            text: 'Login / Register',
            icon: Icons.lock_rounded,
            backgroundColor: AppColors.secondaryFixed,
            textColor: AppColors.onSecondaryFixed,
            onPressed: () {
              // pass desired post-auth route to restore full result
              context.goNamed(
                RouteNames.login,
                extra: RouteNames.analysisResult,
              );
            },
          ),
        ],
      ),
    );
  }
}
