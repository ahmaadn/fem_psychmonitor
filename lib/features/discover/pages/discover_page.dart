import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/widgets/mental_score_line_chart.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/score_log_repository.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/history_viewmodel.dart';
import 'package:fem_psychmonitor/features/history/widgets/emotion_history_chart.dart';
import 'package:fem_psychmonitor/features/home/widgets/today_mood_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
      final vm = context.read<HistoryViewModel>();
      final userId = context.read<AuthViewModel>().currentUser?.id;
      vm.setUserId(userId);
      vm.loadHistory();
      await _loadYearMonths(vm);
      vm.loadChartSeries(days: _periodDays);
      if (_monthScroll.hasClients && _year == now.year) {
        final idx = (now.month - 1).clamp(0, 11);
        _monthScroll.jumpTo(
          (idx * 280.0).clamp(0, _monthScroll.position.maxScrollExtent),
        );
      }
    });
  }

  Future<void> _loadYearMonths(HistoryViewModel vm) async {
    for (final m in _months) {
      await vm.loadCalendar(m.year, m.month);
    }
  }

  Future<void> _loadYear(int year) async {
    setState(() {
      _year = year;
      _months = List.generate(12, (i) => DateTime(year, i + 1));
    });
    final vm = context.read<HistoryViewModel>();
    await _loadYearMonths(vm);
    if (_monthScroll.hasClients) {
      _monthScroll.jumpTo(0);
    }
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
    final labels = _DiscoverL10n.of(context);

    return Scaffold(
      backgroundColor: p.canvas,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header area with gradient ─────────────────────────────────
          _DiscoverHeader(
            year: _year,
            labels: labels,
            tabs: _tabs,
            onPrevYear: () => _loadYear(_year - 1),
            onNextYear: () => _loadYear(_year + 1),
          ),

          // ── Tab content ───────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                // Calendar tab
                ListView.builder(
                  controller: _monthScroll,
                  padding: EdgeInsets.only(
                    top: AppSpacing.xs.h,
                    bottom: 80.h,
                  ),
                  itemCount: _months.length,
                  itemBuilder: (context, index) {
                    return _MonthBlock(
                      month: _months[index],
                      emotions: historyVm.calendarEmotions,
                      onDayTap: _openDaySheet,
                    );
                  },
                ),

                // Journal tab
                _JournalTab(
                  periodDays: _periodDays,
                  onPeriodChanged: (d) {
                    setState(() => _periodDays = d);
                    historyVm.loadChartSeries(days: d);
                  },
                  series: historyVm.chartSeries,
                  scoreSeries: historyVm.scoreSeries,
                  sessions: historyVm.sessions,
                  labels: labels,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDaySheet(DateTime day) async {
    final vm = context.read<HistoryViewModel>();
    final sessions = await vm.loadSessionsForDate(day);
    if (!mounted) return;
    final p = context.palette;
    final labels = _DiscoverL10n.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: p.surface1,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (_, controller) {
              if (sessions.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(AppSpacing.pageX.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Container(
                        width: 36.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: p.divider,
                          borderRadius: AppRadius.chip,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      Text(
                        DateFormat.yMMMMd().format(day),
                        style: AppTypography.subtitle.copyWith(color: p.textPrimary),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Text(
                        labels.emptyDay,
                        style: AppTypography.caption.copyWith(color: p.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      _PrimaryPill(
                        label: labels.iFeelToday,
                        onTap: () async {
                          Navigator.pop(ctx);
                          await _pickMoodForDay(day);
                        },
                      ),
                    ],
                  ),
                );
              }

              final counts = <EmotionLabelType, int>{};
              for (final s in sessions) {
                counts[s.displayEmotion] =
                    (counts[s.displayEmotion] ?? 0) + 1;
              }

              return ListView(
                controller: controller,
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: AppSpacing.md.h),
                      decoration: BoxDecoration(
                        color: p.divider,
                        borderRadius: AppRadius.chip,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat.yMMMMd().format(day),
                    style: AppTypography.subtitle.copyWith(color: p.textPrimary),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: counts.entries
                        .map(
                          (e) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm.w,
                              vertical: AppSpacing.xxs.h,
                            ),
                            decoration: BoxDecoration(
                              color: e.key.surfaceColor,
                              borderRadius: AppRadius.chip,
                              border: Border.all(
                                color: e.key.color.withValues(alpha: 0.3),
                                width: AppBorder.thin,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(e.key.emoji,
                                    style: TextStyle(fontSize: 12.sp)),
                                SizedBox(width: 4.w),
                                Text(
                                  '${e.key.displayName}: ${e.value}',
                                  style: AppTypography.caption
                                      .copyWith(color: p.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  ...sessions.map(
                    (s) => Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.xs.h),
                      decoration: BoxDecoration(
                        color: p.surface1,
                        borderRadius: AppRadius.card,
                        border: Border.all(color: p.divider),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: s.displayEmotion.surfaceColor,
                            borderRadius: AppRadius.tile,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            s.displayEmotion.emoji,
                            style: TextStyle(fontSize: 18.sp),
                          ),
                        ),
                        title: Text(
                          s.displayEmotion.displayName,
                          style:
                              AppTypography.bodyStrong.copyWith(color: p.textPrimary),
                        ),
                        subtitle: Text(
                          '${s.duration.inMinutes}m ${s.duration.inSeconds % 60}s · ${DateFormat.Hm().format(s.startedAt)}',
                          style:
                              AppTypography.caption.copyWith(color: p.textSecondary),
                        ),
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: p.textTertiary, size: 18.sp),
                        onTap: () {
                          Navigator.pop(ctx);
                          context.pushNamed(
                            RouteNames.analysisResult,
                            extra: s.id,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _pickMoodForDay(DateTime day) async {
    final user = context.read<AuthViewModel>().currentUser;
    if (user == null) return;
    final selected = await showTodayMoodSheet(context);
    if (selected == null || !mounted) return;
    await persistDailyMood(userId: user.id, emotion: selected, day: day);
    if (!mounted) return;
    await context.read<HistoryViewModel>().loadCalendar(day.year, day.month);
  }
}

// ── Discover Header ──────────────────────────────────────────────────────────

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader({
    required this.year,
    required this.labels,
    required this.tabs,
    required this.onPrevYear,
    required this.onNextYear,
  });

  final int year;
  final _DiscoverL10n labels;
  final TabController tabs;
  final VoidCallback onPrevYear;
  final VoidCallback onNextYear;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            p.primarySoft,
            Color.lerp(p.primarySoft, p.secondarySoft, 0.08)!,
          ],
        ),
        border: Border(bottom: BorderSide(color: p.divider, width: AppBorder.thin)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pageX.w,
                AppSpacing.md.h,
                AppSpacing.pageX.w,
                0,
              ),
              child: Text(
                labels.discover,
                style: AppTypography.display.copyWith(color: p.textPrimary),
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),

            // Year navigator (only visible in calendar tab)
            AnimatedBuilder(
              animation: tabs,
              builder: (_, _) {
                final isCalendar = tabs.index == 0;
                return AnimatedOpacity(
                  opacity: isCalendar ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.pageX.w),
                    child: Row(
                      children: [
                        _YearChevron(
                          icon: Icons.chevron_left_rounded,
                          onTap: onPrevYear,
                        ),
                        SizedBox(width: AppSpacing.xs.w),
                        Text(
                          '$year',
                          style: AppTypography.bodyStrong.copyWith(
                            color: p.primaryPressed,
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs.w),
                        _YearChevron(
                          icon: Icons.chevron_right_rounded,
                          onTap: onNextYear,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: AppSpacing.sm.h),

            // Tab bar
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppSpacing.pageX.w),
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: p.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.chip,
                ),
                child: TabBar(
                  controller: tabs,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: p.primaryText,
                    borderRadius: AppRadius.chip,
                    boxShadow: [
                      BoxShadow(
                        color: p.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: p.onPrimary,
                  unselectedLabelColor: p.primaryPressed,
                  labelStyle: AppTypography.label,
                  tabs: [
                    Tab(text: labels.calendar),
                    Tab(text: labels.journal),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
          ],
        ),
      ),
    );
  }
}

class _YearChevron extends StatelessWidget {
  const _YearChevron({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.xxs.w),
        decoration: BoxDecoration(
          color: p.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: p.primaryPressed, size: 16.sp),
      ),
    );
  }
}

// ── Primary Pill ─────────────────────────────────────────────────────────────

class PrimaryPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const PrimaryPill({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => _PrimaryPill(label: label, onTap: onTap);
}

class _PrimaryPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [p.primary, p.primaryPressed],
          ),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
              color: p.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTypography.bodyStrong.copyWith(color: p.onPrimary),
        ),
      ),
    );
  }
}

// ── Month Block ──────────────────────────────────────────────────────────────

class _MonthBlock extends StatelessWidget {
  final DateTime month;
  final Map<DateTime, EmotionLabelType> emotions;
  final ValueChanged<DateTime> onDayTap;

  const _MonthBlock({
    required this.month,
    required this.emotions,
    required this.onDayTap,
  });

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = first.weekday % 7; // Sun=0

    // Count mood-tracked days in this month
    final trackedCount = List.generate(daysInMonth, (i) {
      final d = DateTime(month.year, month.month, i + 1);
      return emotions.containsKey(d);
    }).where((v) => v).length;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.pageX.w, AppSpacing.sm.h, AppSpacing.pageX.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat.MMMM().format(month),
                style: AppTypography.bodyStrong.copyWith(color: p.textPrimary),
              ),
              SizedBox(width: AppSpacing.xs.w),
              if (trackedCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: p.primarySoft,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    '$trackedCount',
                    style: AppTypography.label.copyWith(
                      color: p.primaryPressed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.xs.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              childAspectRatio: 1,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) return const SizedBox.shrink();
              final day = index - startWeekday + 1;
              final date = DateTime(month.year, month.month, day);
              final key = DateTime(date.year, date.month, date.day);
              final emotion = emotions[key];
              final today = _isToday(date);

              return InkWell(
                borderRadius: BorderRadius.circular(AppRadius.full),
                onTap: () => onDayTap(date),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: today
                        ? p.primarySoft
                        : (emotion != null
                            ? emotion.surfaceColor
                            : p.primaryWash.withValues(alpha: 0.5)),
                    border: Border.all(
                      color: today
                          ? p.primary
                          : (emotion != null
                              ? p.emotionBase(emotion).withValues(alpha: 0.4)
                              : p.divider),
                      width: today ? AppBorder.thick : AppBorder.thin,
                    ),
                    boxShadow: emotion != null && !today
                        ? [
                            BoxShadow(
                              color: p.emotionBase(emotion).withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (emotion != null)
                        Text(emotion.emoji,
                            style: TextStyle(fontSize: 11.sp))
                      else
                        Text(
                          '$day',
                          style: AppTypography.caption.copyWith(
                            fontWeight:
                                today ? FontWeight.w700 : FontWeight.w500,
                            color: today ? p.primaryPressed : p.textSecondary,
                          ),
                        ),
                      if (emotion != null)
                        Text(
                          '$day',
                          style: AppTypography.label.copyWith(
                            fontWeight: today
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: today ? p.primaryPressed : p.textTertiary,
                            height: 1,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: AppSpacing.xs.h),
          Divider(color: p.divider, height: 1),
        ],
      ),
    );
  }
}

// ── Journal Tab ──────────────────────────────────────────────────────────────

class _JournalTab extends StatelessWidget {
  final int periodDays;
  final ValueChanged<int> onPeriodChanged;
  final List<EmotionSeriesPoint> series;
  final List<ScoreSeriesPoint> scoreSeries;
  final List<DetectionSessionModel> sessions;
  final _DiscoverL10n labels;

  const _JournalTab({
    required this.periodDays,
    required this.onPeriodChanged,
    required this.series,
    required this.scoreSeries,
    required this.sessions,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final periods = {7: '7d', 30: '1m', 180: '6m', 365: '1y'};

    return ListView(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.pageX.w, AppSpacing.md.h, AppSpacing.pageX.w, 80.h),
      children: [
        // Period chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: periods.entries.map((e) {
              final sel = periodDays == e.key;
              return Padding(
                padding: EdgeInsets.only(right: AppSpacing.xs.w),
                child: GestureDetector(
                  onTap: () => onPeriodChanged(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md.w,
                      vertical: AppSpacing.xs.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: sel
                          ? LinearGradient(
                              colors: [p.primary, p.primaryPressed],
                            )
                          : null,
                      color: sel ? null : p.surface1,
                      borderRadius: AppRadius.chip,
                      border: Border.all(
                        color: sel ? p.primaryPressed : p.divider,
                        width: AppBorder.thin,
                      ),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: p.primary.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      e.value,
                      style: AppTypography.label.copyWith(
                        color: sel ? p.onPrimary : p.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: AppSpacing.lg.h),

        // Emotion distribution
        _ChartSection(
          title: labels.emotionDistribution,
          icon: Icons.bar_chart_rounded,
          child: EmotionHistoryChart(series: series, days: periodDays),
        ),
        SizedBox(height: AppSpacing.md.h),

        // Score history
        _ChartSection(
          title: labels.scoreHistory,
          icon: Icons.show_chart_rounded,
          child: MentalScoreLineChart(series: scoreSeries),
        ),
        SizedBox(height: AppSpacing.sm.h),

        // Recordings count badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: AppSpacing.xxs.h,
          ),
          decoration: BoxDecoration(
            color: p.primarySoft,
            borderRadius: AppRadius.chip,
          ),
          child: Text(
            '${labels.recordingsCount}: ${sessions.length}',
            style: AppTypography.caption.copyWith(
              color: p.primaryPressed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: p.surface1,
        borderRadius: AppRadius.card,
        border: Border.all(color: p.divider, width: AppBorder.thin),
        boxShadow: [
          BoxShadow(
            color: p.shadowRaised,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: p.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: p.primaryPressed, size: 14.sp),
              ),
              SizedBox(width: AppSpacing.xs.w),
              Text(
                title,
                style: AppTypography.bodyStrong.copyWith(color: p.textPrimary),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          child,
        ],
      ),
    );
  }
}

// ── L10n ─────────────────────────────────────────────────────────────────────

class _DiscoverL10n {
  final bool isEn;
  const _DiscoverL10n(this.isEn);

  static _DiscoverL10n of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return _DiscoverL10n(code != 'id');
  }

  String get discover => isEn ? 'Discover' : 'Jelajah';
  String get calendar => isEn ? 'Calendar' : 'Kalender';
  String get journal => isEn ? 'Journal' : 'Jurnal';
  String get emptyDay =>
      isEn ? 'No recordings on this date.' : 'Belum ada rekaman di tanggal ini.';
  String get iFeelToday => isEn ? 'I feel today…' : 'Aku merasa hari ini…';
  String get emotionDistribution =>
      isEn ? 'Emotion distribution' : 'Distribusi emosi';
  String get scoreHistory =>
      isEn ? 'Mental score history' : 'Riwayat skor mental';
  String get recordingsCount => isEn ? 'Recordings' : 'Rekaman';
  String get loadPrevYear => isEn ? '← Prev year' : '← Tahun lalu';
  String get loadNextYear => isEn ? 'Next year →' : 'Tahun depan →';
}
