import 'package:file_picker/file_picker.dart';
import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/widgets/voiceprint_orb.dart';
import 'package:fem_psychmonitor/data/viewmodels/home_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/profile_viewmodel.dart';
import 'package:fem_psychmonitor/features/assessment/widgets/current_assessment_card.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadStats();
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  Future<void> _handleUploadAudio() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['wav', 'pcm', 'mp3', 'm4a', 'aac'],
    );
    if (!mounted || picked == null || picked.files.isEmpty) return;
    final path = picked.files.single.path;
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.failedToReadAudioPath)));
      return;
    }
    context.goNamed(RouteNames.recordingProcessing, extra: path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final homeVm = context.watch<HomeViewModel>();
    final profileVm = context.watch<ProfileViewModel>();
    final stats = homeVm.stats;

    final Color orbColor = stats != null && stats.hasDetection
        ? stats.currentMood.color
        : AppColors.primary;

    final hour = DateTime.now().hour;
    final String greeting;
    final String userName = (profileVm.user?.fullName ?? '').trim();
    if (hour >= 5 && hour < 12) {
      greeting = l10n.goodMorning(userName);
    } else if (hour >= 12 && hour < 17) {
      greeting = l10n.goodAfternoon(userName);
    } else {
      greeting = l10n.goodEvening(userName);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              Text(greeting, style: AppTypography.fraunces(size: 30)),
              SizedBox(height: 4.h),
              Text(
                l10n.howAreYouFeeling,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 28.h),
              Center(
                child: VoiceprintOrb(
                  mode: VoiceprintMode.idle,
                  color: orbColor,
                  size: 240,
                  centerTop: stats != null && stats.hasDetection
                      ? '${stats.currentMoodPercentage}%'
                      : null,
                  centerBottom: stats != null && stats.hasDetection
                      ? stats.currentMood.displayName
                      : null,
                ),
              ),
              if (stats != null && !stats.hasDetection) ...[
                SizedBox(height: 12.h),
                Center(
                  child: Text(
                    l10n.noDetectionYet,
                    style: AppTypography.fraunces(size: 20),
                  ),
                ),
                SizedBox(height: 4.h),
                Center(
                  child: SizedBox(
                    width: 260.w,
                    child: Text(
                      l10n.noDetectionDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ] else if (stats != null) ...[
                SizedBox(height: 12.h),
                Center(
                  child: Text(
                    stats.moodDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 32.h),
              _StreakStrip(stats: stats),
              SizedBox(height: 32.h),
              const CurrentAssessmentCard(),
              SizedBox(height: 24.h),
              _RecordCard(
                onRecord: () => context.goNamed(RouteNames.liveRecording),
                onUpload: _handleUploadAudio,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.graphic_eq_rounded,
                      title: stats?.currentMood.displayName ?? l10n.calm,
                      subtitle: l10n.currentMood,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.history_rounded,
                      title: '${stats?.totalRecordings ?? 0}',
                      subtitle: l10n.totalRecordings,
                      accent: AppColors.secondary,
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
}

/// 7-day check-in strip. Order is meaningful (a real weekly sequence), so the
/// day markers are appropriate here — the only place the page uses ordering.
class _StreakStrip extends StatelessWidget {
  final dynamic stats;
  const _StreakStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final streakDays = stats?.streakDays ?? 0;
    final checked = stats != null
        ? (stats.weeklyCheckins as List)
              .map((c) => c.isCheckedIn as bool)
              .toList()
        : List.filled(7, false);
    final todayIndex = DateTime.now().weekday % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.checkInStreak,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.emotionHappiness,
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  l10n.daysCount(streakDays),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.emotionHappiness,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final isChecked = i < checked.length ? checked[i] : false;
            final isToday = i == todayIndex;
            final color = isChecked
                ? AppColors.primary
                : isToday
                ? AppColors.emotionHappiness
                : AppColors.outline;
            return Container(
              width: 38.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: isChecked
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: color, width: isToday ? 1.5 : 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[i],
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: isChecked
                          ? AppColors.primary
                          : isToday
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (isChecked) ...[
                    SizedBox(height: 2.h),
                    Icon(Icons.circle, size: 4.sp, color: AppColors.primary),
                  ],
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  final VoidCallback onRecord;
  final VoidCallback onUpload;
  const _RecordCard({required this.onRecord, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Text(
            l10n.recordYourVoice,
            style: AppTypography.fraunces(
              size: 22,
              weight: FontWeight.w600,
              color: AppColors.onPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.letAiRecognize,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.4,
              color: AppColors.onPrimary.withValues(alpha: 0.82),
            ),
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: onRecord,
            child: Container(
              width: 76.w,
              height: 76.w,
              decoration: BoxDecoration(
                color: AppColors.onPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onPrimary.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.mic_rounded,
                color: AppColors.primary,
                size: 30.sp,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          GestureDetector(
            onTap: onUpload,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(9999.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.upload_file_rounded,
                    size: 14.sp,
                    color: AppColors.onPrimary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    l10n.uploadAudio,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  const _StatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.accent = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 18.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: AppTypography.fraunces(
              size: 22,
              weight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
