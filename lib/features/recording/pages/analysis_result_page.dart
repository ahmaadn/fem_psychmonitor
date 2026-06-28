import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/repositories/recommendation_repository.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/detection_viewmodel.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/app/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/features/history/widgets/timeline_widget.dart';
import 'package:fem_psychmonitor/features/onboarding/models/saran_model.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class AnalysisResultPage extends StatefulWidget {
  final bool isTeaser;

  /// Optional session ID for viewing a past session from history (US-17).
  /// When null, the page renders the just-saved [DetectionViewModel.currentSession]
  /// or the live detector timeline.
  final String? sessionId;

  const AnalysisResultPage({super.key, this.isTeaser = false, this.sessionId});

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  SaranRecommendation? _saran;
  Map<EmotionLabelType, int> _weeklyChart = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExtras());
  }

  Future<void> _loadExtras() async {
    final detectionVm = context.read<DetectionViewModel>();
    final repo = context.read<RecommendationRepository?>();
    final authVm = context.read<AuthViewModel>();

    DetectionSessionModel? session = widget.sessionId == null
        ? detectionVm.currentSession
        : detectionVm.viewedSession ?? detectionVm.currentSession;
    if (widget.sessionId != null && session?.id != widget.sessionId) {
      session = await detectionVm.getSession(widget.sessionId!);
    }

    final mbti = authVm.currentUser?.mbtiResult;

    SaranRecommendation? saran;
    if (repo != null && mbti != null && mbti.isNotEmpty) {
      saran = await repo.getSaran(mbti);
    }

    final weekly = widget.isTeaser
        ? <EmotionLabelType, int>{}
        : await detectionVm.loadWeeklyChart();

    if (!mounted) return;
    setState(() {
      _saran = saran;
      _weeklyChart = weekly;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detector = context.watch<EmotionDetector>();
    final detectionVm = context.watch<DetectionViewModel>();

    final session = widget.sessionId == null
        ? detectionVm.currentSession
        : (detectionVm.viewedSession ?? detectionVm.currentSession);

    final timeline = _buildTimeline(session, detector);
    final dominant = session?.displayEmotion ??
        detector.latest?.label ??
        EmotionLabelType.neutral;
    final dominantConfidence =
        session?.dominantConfidence ?? detector.latest?.confidence ?? 0.0;
    final summaryText = session != null
        ? l10n.resultSummaryDefault
        : (detector.error ?? l10n.resultSummaryDefault);

    final showHotline = _shouldShowHotline(dominant, dominantConfidence);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: l10n.history,
        showBackButton: false,
        isScrollable: false,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.relaxed.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpacing.base.h),
              _buildHeroBanner(
                context,
                l10n,
                dominant: dominant,
                confidence: dominantConfidence,
                summaryText: summaryText,
                isCorrected: session?.correctedEmotion != null,
              ),
              SizedBox(height: AppSpacing.relaxed.h),
              // US-17: Koreksi Hasil — only for a persisted session.
              if (!widget.isTeaser && session != null) ...[
                PrimaryButton(
                  text: session.correctedEmotion == null
                      ? 'Koreksi Hasil Emosi'
                      : 'Ubah Koreksi',
                  prefixIcon: Icons.edit_outlined,
                  onPressed: () => _showCorrectionSheet(context, session),
                ),
                SizedBox(height: AppSpacing.relaxed.h),
              ],
              // US-18: emergency hotline + short weekly chart for significant
              // negative emotions.
              if (showHotline) ...[
                _buildHotlineCard(context),
                SizedBox(height: AppSpacing.relaxed.h),
                _buildWeeklyChartCard(context),
                SizedBox(height: AppSpacing.relaxed.h),
              ],
              _buildSectionCard(
                child: RecordingTimeline(timeline: timeline),
              ),
              SizedBox(height: AppSpacing.relaxed.h),
              ComponentTimeline(timeline: timeline, title: l10n.emotionComponent),
              SizedBox(height: AppSpacing.relaxed.h),
              // US-10: MBTI-tailored recommendation tips.
              if (_saran != null) ...[
                _buildSaranCard(context, dominant),
                SizedBox(height: AppSpacing.relaxed.h),
              ],
              PrimaryButton(
                text: l10n.backToDashboard,
                prefixIcon: Icons.dashboard_customize_rounded,
                onPressed: () => context.goNamed(RouteNames.home),
              ),
              SizedBox(height: AppSpacing.base.h),
              SecondaryButton(
                text: l10n.retakeRecording,
                subText: l10n.retakeRecordingSub,
                icon: Icons.replay_rounded,
                onPressed: () => context.goNamed(RouteNames.liveRecording),
              ),
              if (widget.isTeaser) ...[
                SizedBox(height: AppSpacing.relaxed.h),
                _buildTeaserCard(context, l10n),
              ],
              if (!widget.isTeaser) ...[
                SizedBox(height: AppSpacing.relaxed.h),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppSpacing.base.w),
                  child: Text(
                    l10n.disclaimer,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.extraSpacious.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Convert the session's persisted results (or the live detector timeline)
  /// into the [EmotionResult] shape expected by the timeline widgets.
  List<EmotionResult> _buildTimeline(
    DetectionSessionModel? session,
    EmotionDetector detector,
  ) {
    if (session != null) {
      return session.results.map((r) => r.toEmotionResult()).toList();
    }
    return detector.timeline.toList();
  }

  bool _shouldShowHotline(EmotionLabelType dominant, double confidence) {
    const significant = {
      EmotionLabelType.sad,
      EmotionLabelType.anger,
      EmotionLabelType.fearful,
    };
    return significant.contains(dominant) && confidence >= 0.6;
  }

  Future<void> _showCorrectionSheet(
    BuildContext context,
    DetectionSessionModel session,
  ) async {
    EmotionLabelType? picked = session.correctedEmotion ?? session.dominantEmotion;

    final result = await showModalBottomSheet<EmotionLabelType>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.relaxed.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Koreksi Hasil Emosi',
                      style: Theme.of(innerContext)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    Text(
                      'Pilih emosi yang menurutmu paling akurat mendeskripsikan rekaman ini.',
                      style: Theme.of(innerContext)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    SizedBox(height: AppSpacing.relaxed.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: EmotionLabelType.values.map((e) {
                        final selected = e == picked;
                        return ChoiceChip(
                          label: Text('${e.emoji} ${e.displayName}'),
                          selected: selected,
                          onSelected: (_) =>
                              setSheetState(() => picked = e),
                          selectedColor: e.color,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: AppSpacing.relaxed.h),
                    PrimaryButton(
                      text: 'Simpan Koreksi',
                      onPressed: () => Navigator.of(innerContext).pop(picked),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null && result != session.correctedEmotion) {
      if (!mounted) return;
      final detectionVm = context.read<DetectionViewModel>();
      await detectionVm.correctSession(session.id, result);
      await _loadExtras();
    }
  }

  // ── Section builders ────────────────────────────────────────────────────

  Widget _buildHeroBanner(
    BuildContext context,
    AppLocalizations l10n, {
    required EmotionLabelType dominant,
    required double confidence,
    required String summaryText,
    required bool isCorrected,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.relaxed.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.analysisResult,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onPrimary,
                      letterSpacing: -0.5,
                    ),
              ),
              if (isCorrected) ...[
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'Dikoreksi',
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            l10n.resultSummaryDesc,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.textPrimaryInverse.withValues(alpha: 0.85),
                  height: 1.4,
                ),
          ),
          SizedBox(height: AppSpacing.relaxed.h),
          Center(
            child: CircularPercentIndicator(
              radius: 72.w,
              lineWidth: 10.w,
              percent: confidence.clamp(0.0, 1.0),
              animation: true,
              animationDuration: 1200,
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: AppColors.surface.withValues(alpha: 0.2),
              progressColor: AppColors.secondary,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(confidence * 100).round()}%',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryInverse,
                          letterSpacing: -1.0,
                        ),
                  ),
                  Text(
                    l10n.confidence,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color:
                              AppColors.textPrimaryInverse.withValues(alpha: 0.7),
                          letterSpacing: 1.0,
                        ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.base.h),
          Text(
            l10n.dominantEmotionLabel(dominant.displayName),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryInverse,
                ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            summaryText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13.sp,
                  color: AppColors.textPrimaryInverse.withValues(alpha: 0.8),
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.relaxed.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outline),
      ),
      child: child,
    );
  }

  /// US-18: emergency hotline card for significant negative emotions.
  Widget _buildHotlineCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.relaxed.w),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.phone_in_talk_rounded,
                color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: AppSpacing.base.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Butuh bantuan?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.warning,
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Emosi yang terdeteksi cukup berat. Jika kamu merasa tertekan, jangan ragu menghubungi layanan krisis terdekat.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        height: 1.4,
                        color: AppColors.textPrimary,
                      ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Wrap(
                  spacing: 8.w,
                  children: [
                    _hotlineChip(context, '119', 'Layanan Kesehatan'),
                    _hotlineChip(context, '119 ext. 8', 'Sehat Jiwa'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hotlineChip(BuildContext context, String number, String label) {
    return ActionChip(
      onPressed: () {},
      avatar: Icon(Icons.call, size: 16.sp, color: AppColors.warning),
      label: Text(
        '$number · $label',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.warning,
        ),
      ),
      backgroundColor: Colors.white,
      side: BorderSide(color: AppColors.warning.withValues(alpha: 0.4)),
    );
  }

  /// US-18: short weekly emotion-distribution chart.
  Widget _buildWeeklyChartCard(BuildContext context) {
    final entries = _weeklyChart.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCount = entries.isEmpty
        ? 1
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribusi Emosi 7 Hari',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
          ),
          SizedBox(height: AppSpacing.relaxed.h),
          if (entries.isEmpty)
            Text(
              'Belum ada data minggu ini.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            )
          else
            ...entries.map((e) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
                child: Row(
                  children: [
                    Text(e.key.emoji, style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 60.w,
                      child: Text(
                        e.key.displayName,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: LinearProgressIndicator(
                          value: e.value / maxCount,
                          minHeight: 8.h,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(e.key.color),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 20.w,
                      child: Text(
                        '${e.value}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  /// US-10: MBTI-tailored recommendation tips for the dominant emotion.
  Widget _buildSaranCard(BuildContext context, EmotionLabelType dominant) {
    final tips = _tipsFor(dominant);
    if (tips.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_outlined,
                  color: AppColors.secondary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Saran untukmu',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          ...tips.map(
            (t) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Icon(Icons.circle,
                        size: 6.sp, color: AppColors.secondary),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      t,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12.sp,
                            height: 1.45,
                            color: AppColors.textPrimary,
                          ),
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

  /// Map the dominant emotion to the matching saran tips list. The saran JSON
  /// uses capitalised keys (Happy/Fear/Angry/Sad/Disgust/Neutral).
  List<String> _tipsFor(EmotionLabelType emotion) {
    final e = _saran!.emotions;
    switch (emotion) {
      case EmotionLabelType.happy:
        return e.happy;
      case EmotionLabelType.sad:
        return e.sad;
      case EmotionLabelType.anger:
        return e.angry;
      case EmotionLabelType.fearful:
        return e.fear;
      case EmotionLabelType.disgust:
        return e.disgust;
      case EmotionLabelType.neutral:
        return e.neutral;
    }
  }

  Widget _buildTeaserCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.relaxed.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.wantFullResults,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            l10n.loginRegisterForFull,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
          SizedBox(height: AppSpacing.base.h),
          SecondaryButton(
            text: l10n.loginRegister,
            icon: Icons.lock_rounded,
            backgroundColor: AppColors.secondaryFixed,
            textColor: AppColors.onSecondaryFixed,
            onPressed: () => context.goNamed(
              RouteNames.login,
              extra: RouteNames.analysisResult,
            ),
          ),
        ],
      ),
    );
  }
}
