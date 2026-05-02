import 'package:file_picker/file_picker.dart';
import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
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
  Future<void> _handleUploadAudio() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['wav', 'pcm'],
    );

    if (!mounted || picked == null || picked.files.isEmpty) {
      return;
    }

    final path = picked.files.single.path;
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membaca path file audio.')),
      );
      return;
    }

    context.goNamed(RouteNames.recordingProcessing, extra: path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: 32.h),
              Text(
                'Selamat malam, Elena',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Bagaimana perasaan hatimu saat ini?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15.sp,
                  color: AppColors.onSurface.withAlpha(153),
                ),
              ),
              SizedBox(height: 24.h),
              
              _buildDailyTracker(context),

              SizedBox(height: 32.h),
              MoodOverviewCard(
                mood: 'Tenang',
                percentage: 76,
                description:
                    'Hatimu terasa tenang dan seimbang. Jaga terus ketenangan ini dengan aktivitas relaksasi dan self-care.',
              ),

              SizedBox(height: 48.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
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
                      'Rekam Suaramu',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Biarkan AI mengenali emosi aslimu',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.onSurface.withAlpha(153),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    UploadAudioButton(onTap: _handleUploadAudio),
                  ],
                ),
              ),
              SizedBox(height: 48.h),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      color: AppColors.info,
                      icon: Icons.sentiment_satisfied_alt_rounded,
                      title: 'Tenang',
                      subtitle: 'MOOD SAAT INI',
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      color: AppColors.secondary,
                      icon: Icons.history_rounded,
                      title: '24',
                      subtitle: 'TOTAL REKAMAN',
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
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10.sp,
              color: AppColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTracker(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    // For mock, let's say Monday to Thursday are checked.
    final checkedDays = [true, true, true, true, false, false, false];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Runtutan Check-in Anda',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                Icon(Icons.local_fire_department_rounded, color: const Color(0xFFF59E0B), size: 18.sp),
                SizedBox(width: 4.w),
                Text(
                  '4 Hari',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            )
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final isChecked = checkedDays[index];
            final isToday = index == 4; // Let's say Friday is today
            
            return Container(
              width: 40.w,
              height: 52.h,
              decoration: BoxDecoration(
                color: isChecked 
                    ? AppColors.primary.withAlpha(20) 
                    : (isToday ? AppColors.surface : Colors.transparent),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isChecked 
                      ? AppColors.primary 
                      : (isToday ? const Color(0xFFF59E0B) : AppColors.outline),
                  width: isToday ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[index],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isChecked 
                          ? AppColors.primary 
                          : (isToday ? AppColors.textPrimary : AppColors.textSecondary),
                      fontWeight: isToday || isChecked ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (isChecked) ...[
                    SizedBox(height: 4.h),
                    Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 14.sp),
                  ]
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
