import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CalendarCard extends StatelessWidget {
  final DateRangePickerController datePickerController;
  final Map<DateTime, EmotionLabelType> emotionData;
  final String currentMonthText;
  final VoidCallback? onMonthChanged;
  final Function(DateTime)? updateMonthText;

  const CalendarCard({
    super.key,
    required this.datePickerController,
    required this.emotionData,
    required this.currentMonthText,
    this.onMonthChanged,
    this.updateMonthText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentMonthText,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Row(
                children: [
                  _buildNavButton(
                    Icons.chevron_left_rounded,
                    onTap: () => datePickerController.backward?.call(),
                  ),
                  SizedBox(width: 8.w),
                  _buildNavButton(
                    Icons.chevron_right_rounded,
                    onTap: () => datePickerController.forward?.call(),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 280.h,
            child: SfDateRangePicker(
              backgroundColor: Colors.transparent,
              controller: datePickerController,
              view: DateRangePickerView.month,
              headerHeight: 0,
              selectionRadius: 22,
              selectionShape: .circle,
              monthViewSettings: const DateRangePickerMonthViewSettings(
                showTrailingAndLeadingDates: true,
              ),
              onViewChanged: (DateRangePickerViewChangedArgs args) {
                final midDate = args.visibleDateRange.startDate!.add(
                  Duration(
                    days:
                        args.visibleDateRange.endDate!
                            .difference(args.visibleDateRange.startDate!)
                            .inDays ~/
                        2,
                  ),
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  updateMonthText?.call(midDate);
                });
              },
              monthCellStyle: DateRangePickerMonthCellStyle(
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              cellBuilder: _buildCalendarCell,
            ),
          ),
          SizedBox(height: 24.h),
          Wrap(
            spacing: 16.w,
            runSpacing: 12.h,
            alignment: WrapAlignment.center,
            children: EmotionLabelType.values.map((emotion) {
              return _buildLegendItem(context, emotion: emotion);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCell(
    BuildContext context,
    DateRangePickerCellDetails details,
  ) {
    final DateTime date = details.date;
    final DateTime selectedDate =
        datePickerController.selectedDate ?? DateTime.now();
    final DateTime midDate =
        details.visibleDates[details.visibleDates.length ~/ 2];
    final bool isOutDate = date.month != midDate.month;
    final EmotionLabelType? emotion =
        emotionData[DateTime(date.year, date.month, date.day)];
    final bool isToday =
        date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    Color bgColor = emotion?.color ?? Colors.transparent;
    Color textColor = emotion?.onColor ?? AppColors.primary;
    FontWeight fontWeight = FontWeight.w700;

    if (isOutDate) {
      textColor = Colors.grey.shade400;
      fontWeight = FontWeight.w500;
    } else if (date == selectedDate) {
      bgColor = Colors.transparent;
      textColor = AppColors.onPrimary;
    }

    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 12.sp,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // Tombol navigasi arah panah (Bulan sebelumnya/selanjutnya)
  Widget _buildNavButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outline),
        ),
        child: Icon(icon, size: 20.sp, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required EmotionLabelType emotion,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: emotion.color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          emotion.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 9.sp,
            color: AppColors.primary.withAlpha(179),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
