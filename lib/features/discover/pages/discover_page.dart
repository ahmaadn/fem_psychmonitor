import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/data/models/calendar_day_summary.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/history_viewmodel.dart';
import 'package:fem_psychmonitor/features/discover/widgets/calendar_month_block.dart';
import 'package:fem_psychmonitor/features/discover/widgets/day_detail_sheet.dart';
import 'package:fem_psychmonitor/features/discover/widgets/discover_header.dart';
import 'package:fem_psychmonitor/features/discover/widgets/emotion_legend_strip.dart';
import 'package:fem_psychmonitor/features/discover/widgets/journal_tab.dart';
import 'package:fem_psychmonitor/features/home/widgets/today_mood_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// Discover / Jelajah screen.
///
/// Two tabs:
/// - **Calendar**: 12-month view where each day shows the dominant emotion
///   recorded on that day (the most-frequent label among that day's
///   recordings — see [CalendarDaySummary.dominant]). Tapping a day opens a
///   sheet with that day's full breakdown and a list of its recordings.
/// - **Journal**: charts over a 7d / 1m / 6m / 1y window.
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  int _periodDays = 7;

  late int _year;
  late List<DateTime> _months;
  final ScrollController _monthScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    _year = now.year;
    _months = List.generate(12, (i) => DateTime(_year, i + 1));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vm = context.read<HistoryViewModel>();
      final userId = context.read<AuthViewModel>().currentUser?.id;
      vm.setUserId(userId);
      vm.loadHistory();
      await vm.loadCalendarYear(_year);
      vm.loadChartSeries(days: _periodDays);
      if (!mounted || !_monthScroll.hasClients) return;
      if (_year == now.year) {
        final target = _offsetForMonth(now.month - 1);
        _monthScroll.jumpTo(
          target.clamp(0, _monthScroll.position.maxScrollExtent),
        );
      } else {
        _monthScroll.jumpTo(0);
      }
    });
  }

  /// Approximate scroll offset of month [index] within the calendar list.
  ///
  /// Month blocks are not a fixed height — a month can span five or six
  /// week rows depending on where the 1st falls — so summing per-month
  /// heights lands far closer than multiplying by a single constant.
  double _offsetForMonth(int index) {
    var offset = 0.0;
    for (var i = 0; i < index.clamp(0, 11); i++) {
      offset += _monthBlockHeight(DateTime(_year, i + 1));
    }
    return offset;
  }

  /// Mirrors the layout in `CalendarMonthBlock`: header + weekday row +
  /// N week rows of `AspectRatio(0.86)` cells + trailing spacing/divider.
  double _monthBlockHeight(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    final rows = ((startWeekday + daysInMonth) / 7).ceil();

    // Cell width = (usable width - 6 gutters) / 7; height = width / 0.86.
    final usable =
        MediaQuery.sizeOf(context).width - (AppSpacing.pageX.w * 2);
    final cellW = (usable - (AppSpacing.xxs.w * 6)) / 7;
    final cellH = cellW / 0.86;

    return AppSpacing.md.h + // top padding
        28.h + // month header
        AppSpacing.xs.h +
        16.h + // weekday header
        AppSpacing.xxs.h +
        (rows * cellH) +
        ((rows - 1) * AppSpacing.xxs.h) +
        AppSpacing.md.h +
        AppBorder.thin;
  }

  Future<void> _loadYear(int year) async {
    setState(() {
      _year = year;
      _months = List.generate(12, (i) => DateTime(year, i + 1));
    });
    final vm = context.read<HistoryViewModel>();
    await vm.loadCalendarYear(year);
    if (!mounted || !_monthScroll.hasClients) return;
    _monthScroll.jumpTo(0);
  }

  @override
  void dispose() {
    _monthScroll.dispose();
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final historyVm = context.watch<HistoryViewModel>();

    return Scaffold(
      backgroundColor: p.canvas,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DiscoverHeader(
            year: _year,
            tabs: _tabs,
            onPrevYear: () => _loadYear(_year - 1),
            onNextYear: () => _loadYear(_year + 1),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _CalendarTab(
                  months: _months,
                  summaries: historyVm.calendarSummaries,
                  scrollController: _monthScroll,
                  onDayTap: _openDaySheet,
                ),
                JournalTab(
                  periodDays: _periodDays,
                  onPeriodChanged: (d) {
                    setState(() => _periodDays = d);
                    historyVm.loadChartSeries(days: d);
                  },
                  series: historyVm.chartSeries,
                  scoreSeries: historyVm.scoreSeries,
                  sessions: historyVm.sessions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDaySheet(DateTime day) async {
    if (!mounted) return;
    final vm = context.read<HistoryViewModel>();
    final sessions = await vm.loadSessionsForDate(day);
    if (!mounted) return;
    final summary =
        vm.calendarSummaries[DateTime(day.year, day.month, day.day)];
    await showDayDetailSheet(
      context: context,
      day: day,
      summary: summary,
      sessions: sessions,
      onPickMood: () async {
        Navigator.pop(context);
        await _pickMoodForDay(day);
      },
    );
  }

  Future<void> _pickMoodForDay(DateTime day) async {
    if (!mounted) return;
    final user = context.read<AuthViewModel>().currentUser;
    if (user == null) return;
    final selected = await showTodayMoodSheet(context);
    if (selected == null || !mounted) return;
    await persistDailyMood(userId: user.id, emotion: selected, day: day);
    if (!mounted) return;
    await context.read<HistoryViewModel>().loadCalendarYear(day.year);
  }
}

class _CalendarTab extends StatelessWidget {
  const _CalendarTab({
    required this.months,
    required this.summaries,
    required this.scrollController,
    required this.onDayTap,
  });

  final List<DateTime> months;
  final Map<DateTime, CalendarDaySummary> summaries;
  final ScrollController scrollController;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: AppSpacing.xs.h),        const EmotionLegendStrip(),
        SizedBox(height: AppSpacing.xs.h),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(top: AppSpacing.xs.h, bottom: 80.h),
            // Months are tall and mostly static; isolating each one keeps a
            // scroll from repainting every other month in the viewport.
            addRepaintBoundaries: true,
            itemCount: months.length,
            itemBuilder: (context, index) => RepaintBoundary(
              child: CalendarMonthBlock(
                month: months[index],
                summaries: summaries,
                onDayTap: onDayTap,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
