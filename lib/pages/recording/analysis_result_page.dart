import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/widgets/primary_button.dart';
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

    final countMap = <EmotionLabelType, int>{};
    for (final item in timeline) {
      countMap[item.label] = (countMap[item.label] ?? 0) + 1;
    }

    final total = timeline.isEmpty ? 1 : timeline.length;
    final emotionPercentages = countMap.map(
      (key, value) => MapEntry(key, ((value / total) * 100).round()),
    );
    final emotionEntries = emotionPercentages.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));

    final dominant = detector.latest?.label ?? EmotionLabelType.neutral;
    final dominantConfidence = detector.latest?.confidence ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // APP BAR
            // ==========================================
            CustomAppBar(
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

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 16.h),

                    // ==========================================
                    // HEADER TITLE & BADGE
                    // ==========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          dominant.displayName,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontSize: 40.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: -1.0,
                              ),
                        ),

                        // Live Session Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.infoSurface, // Lavender ringan
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: const BoxDecoration(
                                  color: AppColors.warning, // Titik merah
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'LIVE SESSION',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontSize: 9.sp,
                                      color: AppColors.info,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        detector.lastDetectionPath == null
                            ? 'Belum ada hasil analisis.'
                            : 'Hasil analisis sesi terbaru',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15.sp,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),

                    SizedBox(height: 48.h),

                    // ==========================================
                    // MAIN CIRCULAR PROGRESS (Menggunakan Package)
                    // ==========================================
                    CircularPercentIndicator(
                      radius: 80.w, // Setengah dari lebar yang diinginkan (160)
                      lineWidth: 12.w,
                      percent: dominantConfidence.clamp(0.0, 1.0),
                      animation: true, // Animasi saat loading
                      animationDuration: 1200,
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: Colors.grey.shade200,
                      progressColor: AppColors.primary, // Trust Blue
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
                            'CONFIDENCE',
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
                            'Ringkasan dibuat dari timeline deteksi rekaman terbaru Anda.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15.sp,
                          color: AppColors.primary.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    _buildRecordingTimeline(context, timeline),
                    SizedBox(height: 40.h),
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Component Analysis',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          SizedBox(height: 24.h),

                          if (emotionEntries.isEmpty)
                            Text(
                              'Belum ada komponen emosi. Lakukan rekaman atau upload audio dahulu.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          for (var i = 0; i < emotionEntries.length; i++) ...[
                            _buildEmotionProgressRow(
                              context,
                              emotion: emotionEntries[i].key,
                              percentage: emotionEntries[i].value,
                            ),
                            if (i < emotionEntries.length - 1)
                              SizedBox(height: 20.h),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                    PrimaryButton(
                      text: 'Back to Dashboard',
                      prefixIcon: Icons.dashboard_customize_rounded,
                      onPressed: () {
                        context.goNamed(RouteNames.home);
                      },
                    ),
                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: () {
                        context.goNamed(RouteNames.liveRecording);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 20.h,
                          horizontal: 24.w,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9), // Slate 100
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.replay_rounded,
                              color: AppColors.primary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Retake Recording',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '(Ulangi Rekaman)',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontSize: 12.sp,
                                    color: AppColors.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // ==========================================
                    // FOOTER TEXT
                    // ==========================================
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        'RESULTS GENERATED USING LUMINA AI\nEMOTIONAL ENGINE V4.2. DATA IS ENCRYPTED\nAND PRIVATE.',
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

  // --- KOMPONEN: BARIS PROGRESS EMOSI ---
  Widget _buildEmotionProgressRow(
    BuildContext context, {
    required EmotionLabelType emotion,
    required int percentage,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  emotion.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // Linear Progress Bar (Menggunakan Package)
        LinearPercentIndicator(
          lineHeight: 8.h,
          percent: percentage / 100,
          animation: true,
          animationDuration: 1000,
          backgroundColor: Colors.grey.shade200,
          progressColor: emotion.color,
          barRadius: const Radius.circular(AppRadius.full),
          padding: EdgeInsets.zero, // Penting agar sejajar ujung ke ujung
        ),
      ],
    );
  }

  Widget _buildRecordingTimeline(
    BuildContext context,
    List<EmotionResult> timeline,
  ) {
    final totalSec = timeline.isEmpty ? 0.0 : timeline.last.endSec;
    final totalLabel =
        '${(totalSec ~/ 60).toString().padLeft(2, '0')}:${(totalSec % 60).toInt().toString().padLeft(2, '0')} Total';

    final segmentWidgets = timeline.isEmpty
        ? [
            Expanded(
              child: Container(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
          ]
        : timeline
              .map((e) {
                final segmentDuration = (e.endSec - e.startSec).clamp(
                  1.0,
                  30.0,
                );
                return Expanded(
                  flex: (segmentDuration * 10).round(),
                  child: Container(color: e.label.color),
                );
              })
              .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Timeline
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 20.sp,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Timeline Rekaman',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              totalLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: SizedBox(
            height: 10.h,
            width: double.infinity,
            child: Row(children: segmentWidgets),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AWAL',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10.sp,
                color: AppColors.primary.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'SELESAI',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10.sp,
                color: AppColors.primary.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
