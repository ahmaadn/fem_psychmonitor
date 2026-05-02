import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/widgets/page_header.dart';
import 'package:fem_psychmonitor/widgets/button_widget.dart';
import 'package:fem_psychmonitor/widgets/timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class AnalysisResultPage extends StatelessWidget {
  const AnalysisResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final detector = context.watch<EmotionDetector>();
    final timeline = detector.timeline;

    final dominant = detector.latest?.label ?? EmotionLabelType.neutral;
    final dominantConfidence = detector.latest?.confidence ?? 0.0;

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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 16.h),
                    PageHeader(
                      title: 'Analysis Result',
                      subtitle:
                          'Ringkasan hasil analisis rekaman terbaru Anda.',
                    ),

                    SizedBox(height: 48.h),

                    CircularPercentIndicator(
                      radius: 80.w, // Setengah dari lebar yang diinginkan (160)
                      lineWidth: 12.w,
                      percent: dominantConfidence.clamp(0.0, 1.0),
                      animation: true, // Animasi saat loading
                      animationDuration: 1200,
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: Colors.grey.shade200,
                      progressColor: AppColors.primary,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(dominantConfidence * 100).round()}%',
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  fontSize: 40.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  letterSpacing: -1.0,
                                ),
                          ),
                          Text(
                            'Confidence',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                  letterSpacing: 1.0,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 48.h),
                    Text(
                      'Emosi Dominan ${dominant.displayName}',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        detector.error ??
                            'Ringkasan dibuat dari timeline deteksi rekaman Anda.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15.sp,
                          color: AppColors.primary.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    RecordingTimeline(timeline: timeline),
                    SizedBox(height: 40.h),
                    ComponentTimeline(timeline: timeline),
                    SizedBox(height: 40.h),
                    PrimaryButton(
                      text: 'Back to Dashboard',
                      prefixIcon: Icons.dashboard_customize_rounded,
                      onPressed: () {
                        context.goNamed(RouteNames.home);
                      },
                    ),
                    SizedBox(height: 16.h),
                    SecondaryButton(
                      text: 'Retake Recording',
                      subText: '(Ulangi Rekaman)',
                      icon: Icons.replay_rounded,
                      onPressed: () {
                        context.goNamed(RouteNames.liveRecording);
                      },
                    ),
                    SizedBox(height: 40.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        '*Perhatian: Hasil analisis ini bersifat indikatif dan tidak menggantikan penilaian profesional.',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary.withValues(alpha: 0.4),
                          letterSpacing: 0.5,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 48.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
