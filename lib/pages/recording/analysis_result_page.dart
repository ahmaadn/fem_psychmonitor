import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AnalysisResultPage extends StatelessWidget {
  const AnalysisResultPage({super.key});

  static final Map<EmotionEnumType, int> _emotionPercentages = {
    EmotionEnumType.happiness: 78,
    EmotionEnumType.netral: 64,
    EmotionEnumType.fear: 12,
  };

  @override
  Widget build(BuildContext context) {
    final emotionEntries = _emotionPercentages.entries.toList(growable: false);

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
                          'Calm',
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
                        'Suasana hati pada XX hari XX',
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
                      percent: 0.92,
                      animation: true, // Animasi saat loading
                      animationDuration: 1200,
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: Colors.grey.shade200,
                      progressColor: AppColors.primary, // Trust Blue
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '92%',
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
                      'Emosi Dominan Calm',
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
                        'Your voice pattern suggests a state of centered tranquility and emotional balance.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15.sp,
                          color: AppColors.primary.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    _buildRecordingTimeline(context),
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
    required EmotionEnumType emotion,
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

  Widget _buildRecordingTimeline(BuildContext context) {
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
              '02:45 Total',
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
            child: Row(
              children: [
                Expanded(flex: 30, child: Container(color: AppColors.primary)),
                Expanded(
                  flex: 20,
                  child: Container(
                    color: const Color(0xFFFEF08A),
                  ), // Kuning pastel muda
                ),
                Expanded(flex: 35, child: Container(color: AppColors.primary)),
                Expanded(
                  flex: 15,
                  child: Container(color: AppColors.secondary),
                ),
              ],
            ),
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
