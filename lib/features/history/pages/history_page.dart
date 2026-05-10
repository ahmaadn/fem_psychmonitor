import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/intl_format.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/viewmodels/history_viewmodel.dart';
import 'package:fem_psychmonitor/features/history/widgets/calender_card.dart';
import 'package:fem_psychmonitor/app/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DateRangePickerController _datePickerController =
      DateRangePickerController();
  String _currentMonthText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMonthText(DateTime.now());
      // Load data from viewmodel
      final historyVm = context.read<HistoryViewModel>();
      historyVm.loadAll();
    });
  }

  @override
  void dispose() {
    _datePickerController.dispose();
    super.dispose();
  }

  void _updateMonthText(DateTime date) {
    setState(() {
      _currentMonthText =
          '${MonthEnumType.values[date.month - 1].displayName} ${date.year}';
    });
    // Also refresh calendar data for the new month
    context.read<HistoryViewModel>().loadCalendarData(date.year, date.month);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyVm = context.watch<HistoryViewModel>();
    final sessions = historyVm.sessions;
    final dominantEmotion = historyVm.monthlyDominantEmotion;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(
        title: l10n.historyTitle,
        centerTitle: false,
        showBackButton: false,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    Text(
                      l10n.monthlyReflection,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15.sp,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: l10n.monthDominatedBy),
                          TextSpan(
                            text: dominantEmotion?.label ?? l10n.calmEmotion,
                            style: TextStyle(
                              color: dominantEmotion?.color ??
                                  const Color(0xFF6C5A00),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(text: l10n.monthEndNote),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    CalendarCard(
                      datePickerController: _datePickerController,
                      emotionData: historyVm.calendarData,
                      currentMonthText: _currentMonthText,
                      updateMonthText: _updateMonthText,
                    ),
                    SizedBox(height: 40.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.recentRecordings,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Dynamic session cards from viewmodel
                    if (sessions.isEmpty && !historyVm.isLoading)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.h),
                          child: Text(
                            'Belum ada rekaman',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ...sessions.take(5).map((session) {
                        final isUpload =
                            session.sourceType == DetectionSourceType.upload;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: _buildRecordingCard(
                            context,
                            title: isUpload
                                ? l10n.uploadedAudioHistory
                                : l10n.liveRecordingHistory,
                            subtitle: _formatSessionSubtitle(session),
                            icon: isUpload
                                ? Icons.cloud_upload_outlined
                                : Icons.mic_none_rounded,
                            iconBgColor: isUpload
                                ? const Color(0xFFE2E8F0)
                                : AppColors.primary,
                            iconColor:
                                isUpload ? AppColors.primary : Colors.white,
                            badgeColor: session.dominantEmotion.color,
                            onTap: () =>
                                context.pushNamed(RouteNames.analysisResult),
                          ),
                        );
                      }),
                    SizedBox(height: 120.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSessionSubtitle(DetectionSessionModel session) {
    final date = session.startedAt;
    final duration = session.duration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${date.day}/${date.month}/${date.year} · ${minutes}m ${seconds}s · ${session.dominantEmotion.displayName} (${(session.dominantConfidence * 100).round()}%)';
  }
}

Widget _buildRecordingCard(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
  required Color iconBgColor,
  required Color iconColor,
  required Color badgeColor,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24.sp),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.primary.withAlpha(153),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade400,
            size: 20.sp,
          ),
        ],
      ),
    ),
  );
}
