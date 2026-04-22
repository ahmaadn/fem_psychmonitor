import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/widgets/mood_overview_card.dart';
import 'package:fem_psychmonitor/widgets/upload_audio_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:fem_psychmonitor/widgets/pulsing_mic_button.dart";
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        backgroundColor: Colors.transparent,
        showBackButton: false,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: 32.h),
              Text(
                'Good evening, Elena',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'How is your heart feeling in this moment?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15.sp,
                  color: AppColors.onSurface.withAlpha(153),
                ),
              ),
              SizedBox(height: 32.h),
              MoodOverviewCard(
                mood: 'Serene',
                percentage: 76,
                description:
                    'Your heart feels calm and balanced. Keep nurturing this tranquility with mindful moments and self-care.',
              ),

              SizedBox(height: 48.h),
              Column(
                children: [
                  Center(
                    child: PulsingMicButton(
                      onTap: () {
                        context.goNamed(RouteNames.liveRecording);
                      },
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Record Your Voice',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Let the AI decode your true emotions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                      color: AppColors.onSurface.withAlpha(153),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  UploadAudioButton(
                    onTap: () {
                      context.goNamed(RouteNames.liveRecording);
                    },
                  ),
                ],
              ),
              SizedBox(height: 48.h),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      color: AppColors.infoSurface,
                      icon: Icons.sentiment_satisfied_alt_rounded,
                      title: 'Serene',
                      subtitle: 'CURRENT MOOD',
                      textColor: AppColors.info,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      color: AppColors.secondary,
                      icon: Icons.history_rounded,
                      title: '24',
                      subtitle: 'TOTAL RECORDS',
                      textColor: AppColors.onSurface,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 120.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 28.sp),
          SizedBox(height: 16.h),
          Text(
            title,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10.sp,
              color: textColor.withAlpha(179),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
