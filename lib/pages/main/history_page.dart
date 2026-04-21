import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/intl_format.dart';
import 'package:fem_psychmonitor/widgets/calender_card.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
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

  // Data tiruan (Mock Data) untuk emosi pada tanggal tertentu
  final Map<DateTime, EmotionEnumType> _emotionData = {};

  @override
  void initState() {
    super.initState();
    _generateMockData();
    // Set teks bulan awal (saat ini)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMonthText(DateTime.now());
    });
  }

  @override
  void dispose() {
    _datePickerController.dispose();
    super.dispose();
  }

  // Menghasilkan data acak/statis untuk contoh tampilan kalender
  void _generateMockData() {
    final now = DateTime.now();
    _emotionData[DateTime(now.year, now.month, 1)] = EmotionEnumType.anger;
    _emotionData[DateTime(now.year, now.month, 3)] = EmotionEnumType.sadness;
    _emotionData[DateTime(now.year, now.month, 5)] = EmotionEnumType.happiness;
    _emotionData[DateTime(now.year, now.month, 8)] = EmotionEnumType.disgust;
    _emotionData[DateTime(now.year, now.month, 12)] = EmotionEnumType.fear;
    _emotionData[DateTime(now.year, now.month, 15)] = EmotionEnumType.netral;
    _emotionData[DateTime(now.year, now.month, 18)] = EmotionEnumType.happiness;
  }

  void _updateMonthText(DateTime date) {
    setState(() {
      _currentMonthText =
          '${MonthEnumType.values[date.month - 1].displayName} ${date.year}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomAppBar(
                title: 'History',
                centerTitle: false,
                showBackButton: false,
                isScrollable: true,
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    Text(
                      'Monthly Reflection',
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
                          color: AppColors.primary.withAlpha(178),
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Your emotional landscape has been predominantly ',
                          ),
                          const TextSpan(
                            text: 'Calm ',
                            style: TextStyle(
                              color: Color(0xFF6C5A00),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const TextSpan(
                            text:
                                'this month, with gentle peaks of energy during the weekends.',
                          ),
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
                          'Recent Recordings',
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
                      title: 'Live Recording\nHistory',
                      subtitle: 'Review your real-time\nemotional captures',
                      icon: Icons.mic_none_rounded,
                      iconBgColor: AppColors.primary,
                      iconColor: Colors.white,
                      badgeColor: AppColors.secondary,
                    ),
                    SizedBox(height: 16.h),
                    _buildRecordingCard(
                      context,
                      title: 'Upload\nRecording\nHistory',
                      subtitle: 'Browse your imported\naudio journals',
                      icon: Icons.cloud_upload_outlined,
                      iconBgColor: const Color(0xFFE2E8F0), // Slate 200
                      iconColor: AppColors.primary,
                      badgeColor: AppColors.tertiary,
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
}) {
  return Container(
    padding: EdgeInsets.all(20.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(51),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 20.sp,
            ),
          ],
        ),
      ],
    ),
  );
}
