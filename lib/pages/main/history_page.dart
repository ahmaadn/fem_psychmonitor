import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/intl_format.dart';
import 'package:fem_psychmonitor/widgets/calender_card.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  final Map<DateTime, EmotionLabelType> _emotionData = {};

  @override
  void initState() {
    super.initState();
    _generateMockData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMonthText(DateTime.now());
    });
  }

  @override
  void dispose() {
    _datePickerController.dispose();
    super.dispose();
  }

  void _generateMockData() {
    final now = DateTime.now();
    _emotionData[DateTime(now.year, now.month, 1)] = EmotionLabelType.anger;
    _emotionData[DateTime(now.year, now.month, 3)] = EmotionLabelType.sad;
    _emotionData[DateTime(now.year, now.month, 5)] = EmotionLabelType.happy;
    _emotionData[DateTime(now.year, now.month, 8)] = EmotionLabelType.disgust;
    _emotionData[DateTime(now.year, now.month, 12)] = EmotionLabelType.fearful;
    _emotionData[DateTime(now.year, now.month, 15)] = EmotionLabelType.neutral;
    _emotionData[DateTime(now.year, now.month, 18)] = EmotionLabelType.happy;
  }

  void _updateMonthText(DateTime date) {
    setState(() {
      _currentMonthText =
          '${MonthEnumType.values[date.month - 1].displayName} ${date.year}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                            text: l10n.calmEmotion,
                            style: TextStyle(
                              color: Color(0xFF6C5A00),
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
                      emotionData: _emotionData,
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
                    _buildRecordingCard(
                      context,
                      title: l10n.liveRecordingHistory,
                      subtitle: l10n.liveRecordingSubtitle,
                      icon: Icons.mic_none_rounded,
                      iconBgColor: AppColors.primary,
                      iconColor: Colors.white,
                      badgeColor: AppColors.secondary,
                      onTap: () => context.pushNamed(RouteNames.analysisResult),
                    ),
                    SizedBox(height: 16.h),
                    _buildRecordingCard(
                      context,
                      title: l10n.uploadedAudioHistory,
                      subtitle: l10n.uploadedAudioSubtitle,
                      icon: Icons.cloud_upload_outlined,
                      iconBgColor: const Color(0xFFE2E8F0),
                      iconColor: AppColors.primary,
                      badgeColor: AppColors.tertiary,
                      onTap: () => context.pushNamed(RouteNames.analysisResult),
                    ),
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
