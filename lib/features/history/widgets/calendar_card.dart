import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/widgets/session_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CalendarCard extends StatelessWidget {
  final DateRangePickerController datePickerController;
  final Map<DateTime, EmotionLabelType> emotionData;
  final String currentMonthText;
  final VoidCallback? onMonthChanged;
  final Function(DateTime)? updateMonthText;
  final ValueChanged<DateTime>? onDateSelected;

  const CalendarCard({
    super.key,
    required this.datePickerController,
    required this.emotionData,
    required this.currentMonthText,
    this.onMonthChanged,
    this.updateMonthText,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final dataVersion = Object.hashAll(
      emotionData.entries.map(
        (entry) =>
            Object.hash(entry.key.millisecondsSinceEpoch, entry.value.name),
      ),
    );

    return SessionCard(
      padding: EdgeInsets.all(AppSpacing.xl.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentMonthText,
                style: AppTypography.subtitle.copyWith(color: p.textPrimary),
              ),
              Row(
                children: [
                  _buildNavButton(
                    Icons.chevron_left_rounded,
                    onTap: () => datePickerController.backward?.call(),
                  ),
                  SizedBox(width: AppSpacing.xs.w),
                  _buildNavButton(
                    Icons.chevron_right_rounded,
                    onTap: () => datePickerController.forward?.call(),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl.h),
          SizedBox(
            height: 280.h,
            child: SfDateRangePicker(
              key: ValueKey(dataVersion),
              backgroundColor: Colors.transparent,
              controller: datePickerController,
              view: DateRangePickerView.month,
              headerHeight: 0,
              selectionRadius: 22,
              selectionShape: .circle,
              monthViewSettings: const DateRangePickerMonthViewSettings(
                showTrailingAndLeadingDates: true,
              ),
              onSelectionChanged: (args) {
                final value = args.value;
                if (value is DateTime) {
                  onDateSelected?.call(value);
                }
              },
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
                textStyle: AppTypography.label.copyWith(color: p.textPrimary),
              ),
              cellBuilder: _buildCalendarCell,
            ),
          ),
          SizedBox(height: AppSpacing.xl.h),
          Wrap(
            spacing: AppSpacing.md.w,
            runSpacing: AppSpacing.sm.h,
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
    final p = context.palette;
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

    Color bgColor = Colors.transparent;
    Color textColor = p.textPrimary;
    FontWeight fontWeight = FontWeight.w600;

    if (emotion != null) {
      bgColor = p.emotionBase(emotion).withValues(alpha: 0.22);
      textColor = p.emotionText(emotion);
      fontWeight = FontWeight.w700;
    }

    if (isOutDate) {
      textColor = p.textTertiary;
      fontWeight = FontWeight.w500;
    } else if (_isSameDate(date, selectedDate)) {
      bgColor = p.primaryFill;
      textColor = p.onPrimary;
    }

    return Container(
      margin: EdgeInsets.all(AppSpacing.xxs.w),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: p.primaryText, width: AppBorder.thick)
            : null,
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: AppTypography.label.copyWith(
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Tombol navigasi arah panah (Bulan sebelumnya/selanjutnya)
  Widget _buildNavButton(IconData icon, {required VoidCallback onTap}) {
    return Builder(
      builder: (context) {
        final p = context.palette;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: p.surface1,
              shape: BoxShape.circle,
              border: Border.all(color: p.divider),
            ),
            child: Icon(icon, size: 20.sp, color: p.textSecondary),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required EmotionLabelType emotion,
  }) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: p.emotionBase(emotion),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: AppSpacing.xxs.w + 2),
        Text(
          emotion.label,
          style: AppTypography.label.copyWith(
            fontSize: 9.sp,
            color: p.emotionText(emotion),
          ),
        ),
      ],
    );
  }
}
