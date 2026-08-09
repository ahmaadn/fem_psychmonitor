import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/data/models/calendar_day_summary.dart';
import 'package:fem_psychmonitor/features/discover/widgets/calendar_day_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// One month of the Discover calendar: title, weekday header, and day grid.
class CalendarMonthBlock extends StatelessWidget {
  const CalendarMonthBlock({
    super.key,
    required this.month,
    required this.summaries,
    required this.onDayTap,
  });

  final DateTime month;
  final Map<DateTime, CalendarDaySummary> summaries;
  final ValueChanged<DateTime> onDayTap;

  /// Grid cells are slightly taller than wide so the emoji and the date
  /// number can both sit at a legible size.
  static const double _cellAspectRatio = 0.86;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = Localizations.localeOf(context).toString();
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = first.weekday % 7; // Sun = 0

    // Resolved once per month instead of once per day cell.
    final now = DateTime.now();
    final isCurrentMonth = now.year == month.year && now.month == month.month;

    var trackedDays = 0;
    var totalRecordings = 0;
    for (var i = 1; i <= daysInMonth; i++) {
      final s = summaries[DateTime(month.year, month.month, i)];
      if (s == null || s.total == 0) continue;
      trackedDays++;
      totalRecordings += s.total;
    }

    // Build the day grid as plain Rows. A shrink-wrapped GridView nested in
    // the outer ListView has to lay out every cell of every month on each
    // frame, which is the main source of the scroll stutter here.
    final cellCount = startWeekday + daysInMonth;
    final rowCount = (cellCount / 7).ceil();
    final spacing = AppSpacing.xxs;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageX.w,
        AppSpacing.md.h,
        AppSpacing.pageX.w,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MonthHeader(
            month: month,
            locale: locale,
            trackedDays: trackedDays,
            totalRecordings: totalRecordings,
          ),
          SizedBox(height: AppSpacing.xs.h),
          _WeekdayHeader(locale: locale),
          SizedBox(height: AppSpacing.xxs.h),
          for (var row = 0; row < rowCount; row++) ...[
            if (row > 0) SizedBox(height: spacing.h),
            Row(
              children: [
                for (var col = 0; col < 7; col++) ...[
                  if (col > 0) SizedBox(width: spacing.w),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: _cellAspectRatio,
                      child: _cell(
                        row * 7 + col,
                        startWeekday,
                        cellCount,
                        isCurrentMonth,
                        now,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          SizedBox(height: AppSpacing.md.h),
          Divider(color: p.divider, height: AppBorder.thin),
        ],
      ),
    );
  }

  /// One grid slot. Leading slots before the 1st and trailing slots past the
  /// last day render as blanks so every row keeps seven equal columns.
  Widget _cell(
    int index,
    int startWeekday,
    int cellCount,
    bool isCurrentMonth,
    DateTime now,
  ) {
    if (index < startWeekday || index >= cellCount) {
      return const SizedBox.shrink();
    }
    final day = index - startWeekday + 1;
    final date = DateTime(month.year, month.month, day);
    return CalendarDayTile(
      date: date,
      summary: summaries[date],
      isToday: isCurrentMonth && now.day == day,
      onTap: () => onDayTap(date),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.locale,
    required this.trackedDays,
    required this.totalRecordings,
  });

  final DateTime month;
  final String locale;
  final int trackedDays;
  final int totalRecordings;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Row(
      children: [
        Text(
          DateFormat.MMMM(locale).format(month),
          style: AppTypography.subtitle.copyWith(color: p.textPrimary),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    // Sunday-first to match the grid's `weekday % 7` offset.
    final format = DateFormat.E(locale);
    final labels = List.generate(7, (i) {
      // 2024-01-07 is a Sunday; walk forward to name each column.
      return format.format(DateTime(2024, 1, 7 + i));
    });

    return Row(
      children: labels
          .map(
            (l) => Expanded(
              child: Center(
                child: Text(
                  l,
                  style: AppTypography.micro.copyWith(color: p.textTertiary),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
