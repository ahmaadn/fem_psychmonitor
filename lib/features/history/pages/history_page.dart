import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/intl_format.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:fem_psychmonitor/data/viewmodels/history_viewmodel.dart';
import 'package:fem_psychmonitor/features/assessment/widgets/current_assessment_card.dart';
import 'package:fem_psychmonitor/features/history/widgets/calendar_card.dart';
import 'package:fem_psychmonitor/features/history/widgets/emotion_history_chart.dart';
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
      final today = DateTime.now();
      _datePickerController.selectedDate = DateTime(
        today.year,
        today.month,
        today.day,
      );
      _updateMonthText(today);
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
    context.read<HistoryViewModel>().loadCalendarData(date.year, date.month);
  }

  void _selectDate(DateTime date) {
    final selected = DateTime(date.year, date.month, date.day);
    context.read<HistoryViewModel>().selectDate(selected);
    final visibleMonthChanged =
        _currentMonthText !=
        '${MonthEnumType.values[selected.month - 1].displayName} ${selected.year}';
    if (visibleMonthChanged) {
      _updateMonthText(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyVm = context.watch<HistoryViewModel>();
    final sessions = historyVm.sessions;
    final dominantEmotion = historyVm.monthlyDominantEmotion;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Text(
                l10n.monthlyReflection,
                style: AppTypography.fraunces(size: 30),
              ),
              SizedBox(height: 10.h),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(text: l10n.monthDominatedBy),
                    TextSpan(
                      text: dominantEmotion?.label ?? l10n.calmEmotion,
                      style: TextStyle(
                        color:
                            dominantEmotion?.color ??
                            AppColors.emotionHappiness,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: l10n.monthEndNote),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              CalendarCard(
                datePickerController: _datePickerController,
                emotionData: historyVm.calendarData,
                currentMonthText: _currentMonthText,
                updateMonthText: _updateMonthText,
                onDateSelected: _selectDate,
              ),
              SizedBox(height: 24.h),
              _ChartCard(series: historyVm.chartSeries),
              SizedBox(height: 24.h),
              const CurrentAssessmentCard(),
              SizedBox(height: 28.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.recentRecordings,
                    style: AppTypography.fraunces(size: 20),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(9999.r),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Text(
                      _formatSelectedDate(historyVm.selectedDate),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              if (sessions.isEmpty && !historyVm.isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 28.h),
                  child: Center(
                    child: SizedBox(
                      width: 240.w,
                      child: Text(
                        l10n.noRecordingsYet,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
              else
                ...sessions.map((session) {
                  final isUpload =
                      session.sourceType == DetectionSourceType.upload;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _RecordingCard(
                      title: isUpload
                          ? l10n.uploadedAudioHistory
                          : l10n.liveRecordingHistory,
                      subtitle: _formatSessionSubtitle(session),
                      isUpload: isUpload,
                      badgeColor: session.displayEmotion.color,
                      onTap: () => context.pushNamed(
                        RouteNames.analysisResult,
                        extra: session.id,
                      ),
                    ),
                  );
                }),
              SizedBox(height: 120.h),
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
    final base =
        '${date.day}/${date.month}/${date.year} · ${minutes}m ${seconds}s · ${session.displayEmotion.displayName} (${(session.displayConfidence * 100).round()}%)';
    final note = session.note?.trim();
    return (note == null || note.isEmpty) ? base : '$base\n$note';
  }

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Hari Ini';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ───────────────────────── 7-day chart ─────────────────────────
class _ChartCard extends StatelessWidget {
  final List<EmotionSeriesPoint> series;
  const _ChartCard({required this.series});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tren Emosi 7 Hari', style: AppTypography.fraunces(size: 16)),
          SizedBox(height: 14.h),
          EmotionHistoryChart(series: series),
        ],
      ),
    );
  }
}

// ───────────────────────── Recording card ─────────────────────────
class _RecordingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isUpload;
  final Color badgeColor;
  final VoidCallback? onTap;
  const _RecordingCard({
    required this.title,
    required this.subtitle,
    required this.isUpload,
    required this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isUpload
        ? Icons.cloud_upload_outlined
        : Icons.graphic_eq_rounded;
    final iconBg = isUpload ? AppColors.secondaryFixed : AppColors.primaryFixed;
    final iconColor = isUpload ? AppColors.onSecondaryFixed : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22.sp),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2.5),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.fraunces(
                      size: 15,
                      weight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
