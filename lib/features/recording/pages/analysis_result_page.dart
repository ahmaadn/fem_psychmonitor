import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/date_utils.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/mental_health_score.dart';
import 'package:fem_psychmonitor/app/utils/recommendation_engine.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/app/widgets/app_bottom_sheet.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_emoji.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_radar_chart.dart';
import 'package:fem_psychmonitor/app/widgets/session_card.dart';
import 'package:fem_psychmonitor/app/widgets/voiceprint_orb.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/repositories/recommendation_repository.dart';
import 'package:fem_psychmonitor/data/repositories/score_log_repository.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/detection_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/history_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/profile_viewmodel.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/features/history/widgets/timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AnalysisResultPage extends StatefulWidget {
  final bool isTeaser;
  final String? sessionId;

  const AnalysisResultPage({super.key, this.isTeaser = false, this.sessionId});

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  RecommendationResult? _saranResult;
  Map<EmotionLabelType, int> _weeklyChart = {};

  TextEditingController? _noteController;
  String? _noteSessionId;
  bool _isSavingNote = false;
  bool _noteSavedTick = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExtras());
  }

  @override
  void dispose() {
    _noteController?.dispose();
    super.dispose();
  }

  void _ensureNoteController(DetectionSessionModel? session) {
    if (session == null) return;
    if (_noteController == null) {
      _noteController = TextEditingController(text: session.note ?? '');
      _noteSessionId = session.id;
    } else if (_noteSessionId != session.id) {
      _noteController!.text = session.note ?? '';
      _noteSessionId = session.id;
    }
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

    if (!mounted) return;
    _ensureNoteController(session);

    final user = authVm.currentUser;
    final isEn = context.read<LocaleProvider>().isEnglish;
    final emotion = session?.displayEmotion ?? EmotionLabelType.neutral;

    RecommendationResult? saranResult;
    if (repo != null && user != null) {
      saranResult = await repo.getRecommendations(
        ocean: user.oceanScores,
        emotion: emotion,
        psychScore: user.psychScore,
        isEnglish: isEn,
      );
    }

    final weekly = widget.isTeaser
        ? <EmotionLabelType, int>{}
        : await detectionVm.loadWeeklyChart();

    if (!mounted) return;
    setState(() {
      _saranResult = saranResult;
      _weeklyChart = weekly;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final detector = context.watch<EmotionDetector>();
    final detectionVm = context.watch<DetectionViewModel>();

    final session = widget.sessionId == null
        ? detectionVm.currentSession
        : (detectionVm.viewedSession ?? detectionVm.currentSession);

    _ensureNoteController(session);

    final timeline = _buildTimeline(session, detector);
    final liveDominant = dominantFromResults(detector.timeline);
    final dominant = session?.displayEmotion ?? liveDominant.emotion;
    final dominantConfidence =
        session?.displayConfidence ?? liveDominant.confidence;
    final summaryText = session != null
        ? l10n.resultSummaryDefault
        : (detector.error ?? l10n.resultSummaryDefault);

    final showHotline = _shouldShowHotline(dominant, dominantConfidence);

    return Scaffold(
      backgroundColor: p.canvas,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: p.textSecondary, size: 22.sp),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(color: p.canvas),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageX.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSpacing.xs.h),
                _Hero(
                  dominant: dominant,
                  confidence: dominantConfidence,
                  isCorrected: session?.correctedEmotion != null,
                  summaryText: summaryText,
                ),
                SizedBox(height: AppSpacing.xl.h),
                if (!widget.isTeaser && session != null) ...[
                  Builder(
                    builder: (context) {
                      final canCorrect = isTodayLocal(session.startedAt);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _CorrectionButton(
                            corrected: session.correctedEmotion != null,
                            enabled: canCorrect,
                            onTap: canCorrect
                                ? () => _showCorrectionSheet(context, session)
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Koreksi emosi hanya bisa dilakukan pada hari yang sama dengan rekaman.',
                                        ),
                                      ),
                                    );
                                  },
                          ),
                          if (!canCorrect)
                            Padding(
                              padding: EdgeInsets.only(top: AppSpacing.xxs.h),
                              child: Text(
                                'Koreksi hanya tersedia di hari yang sama.',
                                style: AppTypography.caption.copyWith(
                                  color: p.textTertiary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.md.h),
                ],
                if (!widget.isTeaser &&
                    session != null &&
                    _noteController != null)
                  _NoteCard(
                    controller: _noteController!,
                    saving: _isSavingNote,
                    savedTick: _noteSavedTick,
                    onChanged: (_) {
                      if (_noteSavedTick) {
                        setState(() => _noteSavedTick = false);
                      }
                    },
                    onSave: () => _saveNote(session),
                  ),
                if (!widget.isTeaser && session != null) ...[
                  SizedBox(height: AppSpacing.md.h),
                  _ScoreCalculationCard(session: session),
                ],
                if (session?.selfReportEmotion != null) ...[
                  SizedBox(height: AppSpacing.sm.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Self-report: ',
                        style: AppTypography.caption.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                      EmotionEmoji(
                        asset: session!.selfReportEmotion!.emojiAsset,
                        size: 14,
                      ),
                      SizedBox(width: AppSpacing.xxs.w),
                      Text(
                        session.selfReportEmotion!.displayName,
                        style: AppTypography.caption.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: AppSpacing.md.h),
                SessionCard(
                  child: EmotionRadarChart(
                    title: 'Distribusi emosi',
                    values:
                        session?.averageProbs ??
                        (detector.latest?.allProbs ??
                            List.filled(EmotionLabelType.values.length, 0)),
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),
                if (showHotline) ...[
                  _HotlineCard(onCall: (n) => _launchHotline(context, l10n, n)),
                  SizedBox(height: AppSpacing.md.h),
                  _WeeklyChart(chart: _weeklyChart),
                  SizedBox(height: AppSpacing.md.h),
                ],
                SessionCard(child: RecordingTimeline(timeline: timeline)),
                SizedBox(height: AppSpacing.md.h),
                ComponentTimeline(
                  timeline: timeline,
                  title: l10n.emotionComponent,
                ),
                SizedBox(height: AppSpacing.md.h),
                if (_saranResult != null && _saranResult!.items.isNotEmpty) ...[
                  _SaranCard(
                    tips: _saranResult!.items.map((e) => e.text).toList(),
                  ),
                  SizedBox(height: AppSpacing.md.h),
                ],
                SecondaryButton(
                  text: l10n.retakeRecording,
                  subText: l10n.retakeRecordingSub,
                  textColor: p.primaryText,
                  borderColor: p.primary,
                  icon: Icons.replay_rounded,
                  onPressed: () => context.goNamed(RouteNames.liveRecording),
                ),
                if (!widget.isTeaser && session != null) ...[
                  SizedBox(height: AppSpacing.sm.h),
                  AppTextButton(
                    text: 'Hapus rekaman ini',
                    color: p.warning,
                    onPressed: () => _confirmDelete(session),
                  ),
                ],
                if (widget.isTeaser) ...[
                  SizedBox(height: AppSpacing.md.h),
                  const _TeaserCard(),
                ],
                if (!widget.isTeaser) ...[
                  SizedBox(height: AppSpacing.md.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
                    child: Text(
                      l10n.disclaimer,
                      textAlign: TextAlign.center,
                      style: AppTypography.micro.copyWith(
                        color: p.textSecondary.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: AppSpacing.huge.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Future<void> _confirmDelete(DetectionSessionModel session) async {
    final p = context.palette;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus rekaman?'),
        content: const Text(
          'Rekaman dihapus dari riwayat. Skor kesehatan mental tidak diubah.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Hapus',
              style: AppTypography.button.copyWith(color: p.warning),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final detectionVm = context.read<DetectionViewModel>();
    final success = await detectionVm.deleteSession(session.id);
    if (!mounted) return;
    if (success) {
      try {
        context.read<HistoryViewModel>().loadHistory();
      } catch (_) {}
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed(RouteNames.discover);
      }
    } else if (detectionVm.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(detectionVm.error!)));
    }
  }

  Future<void> _showCorrectionSheet(
    BuildContext context,
    DetectionSessionModel session,
  ) async {
    final p = context.palette;
    if (!isTodayLocal(session.startedAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Koreksi emosi hanya bisa dilakukan pada hari yang sama dengan rekaman.',
          ),
        ),
      );
      return;
    }

    EmotionLabelType? picked =
        session.correctedEmotion ?? session.dominantEmotion;
    final detectionVm = context.read<DetectionViewModel>();

    final result = await showAppBottomSheet<EmotionLabelType>(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerContext, setSheetState) {
            final bottomInset = MediaQuery.viewInsetsOf(innerContext).bottom;
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl.w,
                  AppSpacing.md.h,
                  AppSpacing.xl.w,
                  AppSpacing.md.h + bottomInset,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppSheetHandle(),
                      SizedBox(height: AppSpacing.sm.h),
                      Text(
                        'Koreksi Hasil Emosi',
                        style: AppTypography.subtitle,
                      ),
                      SizedBox(height: AppSpacing.xxs.h),
                      Text(
                        'Pilih emosi yang menurutmu paling akurat mendeskripsikan rekaman ini.',
                        style: AppTypography.caption.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Wrap(
                        spacing: AppSpacing.xs.w,
                        runSpacing: AppSpacing.xs.h,
                        children: EmotionLabelType.values.map((e) {
                          final selected = e == picked;
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                EmotionEmoji(asset: e.emojiAsset, size: 16),
                                SizedBox(width: AppSpacing.xxs.w),
                                Text(e.displayName),
                              ],
                            ),
                            selected: selected,
                            onSelected: (_) => setSheetState(() => picked = e),
                            selectedColor: e.color,
                            labelStyle: AppTypography.bodyStrong.copyWith(
                              color: selected ? p.onPrimary : p.textPrimary,
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      PrimaryButton(
                        text: 'Simpan Koreksi',
                        onPressed: () => Navigator.of(innerContext).pop(picked),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || result == session.correctedEmotion) return;
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Simpan koreksi emosi?'),
        content: const Text(
          'Emosi rekaman akan dikoreksi. Skor kesehatan mental dan saran akan diperbarui. Yakin simpan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, simpan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await detectionVm.correctSession(session.id, result);
    final updated = detectionVm.currentSession?.id == session.id
        ? detectionVm.currentSession
        : detectionVm.viewedSession;
    if (updated != null) {
      await _applyCorrectionMentalHealthImpact(session, updated);
    }
    await _loadExtras();
  }

  Future<void> _applyCorrectionMentalHealthImpact(
    DetectionSessionModel previousSession,
    DetectionSessionModel updatedSession,
  ) async {
    final profileVm = context.read<ProfileViewModel>();
    final authVm = context.read<AuthViewModel>();
    final l10n = AppLocalizations.of(context)!;

    var user = profileVm.user;
    if (user == null) {
      await profileVm.loadProfile();
      user = profileVm.user;
    }
    user ??= authVm.currentUser;
    final currentScore = user?.psychScore;
    if (user == null || currentScore == null) return;

    final updatedScore = applyDetectionMentalHealthImpact(
      currentScore: currentScore,
      session: updatedSession,
      previousSession: previousSession,
    );
    final classKey = psychClassKeyForScore(updatedScore);

    await profileVm.updateProfile(
      user.copyWith(psychScore: updatedScore, psychClass: classKey),
      l10n,
    );
    await ScoreLogRepository().append(
      userId: user.id,
      score: updatedScore,
      reason: 'session_correct',
    );
  }

  Future<void> _saveNote(DetectionSessionModel session) async {
    final text = _noteController?.text;
    final detectionVm = context.read<DetectionViewModel>();
    setState(() {
      _isSavingNote = true;
      _noteSavedTick = false;
    });
    await detectionVm.updateNote(session.id, text);
    if (!mounted) return;
    setState(() {
      _isSavingNote = false;
      _noteSavedTick = detectionVm.error == null;
    });
  }

  Future<void> _launchHotline(
    BuildContext context,
    AppLocalizations l10n,
    String dialNumber,
  ) async {
    final uri = Uri.parse('tel:$dialNumber');
    final messenger = ScaffoldMessenger.of(context);
    try {
      final launched = await canLaunchUrl(uri) && await launchUrl(uri);
      if (!launched && mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.hotlineLaunchFailed)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.hotlineLaunchFailed)));
    }
  }
}

// ───────────────────────── Hero ─────────────────────────
class _Hero extends StatelessWidget {
  final EmotionLabelType dominant;
  final double confidence;
  final bool isCorrected;
  final String summaryText;
  const _Hero({
    required this.dominant,
    required this.confidence,
    required this.isCorrected,
    required this.summaryText,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    return SessionCard(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.xxl.h,
        horizontal: AppSpacing.lg.w,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.analysisResult,
                style: AppTypography.tabLabel.copyWith(
                  letterSpacing: 1.2,
                  color: p.textSecondary,
                ),
              ),
              if (isCorrected)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs.w,
                    vertical: AppSpacing.xxs.h,
                  ),
                  decoration: BoxDecoration(
                    color: p.secondarySoft,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    'Dikoreksi',
                    style: AppTypography.badge.copyWith(color: p.secondaryText),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          VoiceprintOrb(
            mode: VoiceprintMode.static,
            color: p.emotionBase(dominant),
            size: 220,
            confidence: confidence,
            centerTop: '${(confidence * 100).round()}%',
            centerBottom: l10n.confidence.toUpperCase(),
          ),
          SizedBox(height: AppSpacing.sm.h),
          EmotionEmoji(asset: dominant.emojiAsset, size: 40),
          SizedBox(height: AppSpacing.xxs.h),
          Text(dominant.displayName, style: AppTypography.subtitle),
          SizedBox(height: AppSpacing.xxs.h),
          Text(
            l10n.dominantEmotionLabel(dominant.displayName),
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: p.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Text(
            summaryText,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              height: 1.5,
              color: p.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Correction button ─────────────────────────
class _CorrectionButton extends StatelessWidget {
  final bool corrected;
  final bool enabled;
  final VoidCallback onTap;
  const _CorrectionButton({
    required this.corrected,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.buttonY.h,
          ),
          decoration: p.card(radius: AppRadius.md),
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                size: AppSpacing.lg.sp,
                color: p.primaryText,
              ),
              SizedBox(width: AppSpacing.xs.w),
              Expanded(
                child: Text(
                  corrected ? 'Ubah Koreksi' : 'Koreksi Hasil Emosi',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: p.primaryText,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: p.textSecondary,
                size: AppSpacing.lg.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreCalculationCard extends StatelessWidget {
  const _ScoreCalculationCard({required this.session});

  final DetectionSessionModel session;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final profileVm = context.watch<ProfileViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final user = profileVm.user ?? authVm.currentUser;
    final currentScore = user?.psychScore;
    final breakdown = mentalHealthScoreBreakdown(session);
    final sign = breakdown.delta > 0 ? '+' : '';
    final confidencePercent = (breakdown.modelConfidence * 100).round();
    final effectivePercent = (breakdown.effectiveConfidence * 100).round();
    final weighted = breakdown.weightedImpact.toStringAsFixed(2);
    final impact = _formatNumber(breakdown.impactWeight);

    return SessionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSpacing.xxxl.w,
                height: AppSpacing.xxxl.w,
                decoration: BoxDecoration(
                  color: p.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calculate_rounded,
                  color: p.primaryText,
                  size: AppSpacing.md.sp,
                ),
              ),
              SizedBox(width: AppSpacing.xs.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perhitungan Skor Sesi Ini',
                      style: AppTypography.subtitle,
                    ),
                    SizedBox(height: AppSpacing.xxs.h),
                    Text(
                      'Menjelaskan dampak rekaman ini ke skor mental health.',
                      style: AppTypography.caption.copyWith(
                        height: 1.35,
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          _FormulaLine(
            label: 'Emosi yang dipakai',
            value: breakdown.emotion.displayName,
            valueEmojiAsset: breakdown.emotion.emojiAsset,
          ),
          _FormulaLine(label: 'Confidence model', value: '$confidencePercent%'),
          if (breakdown.isCorrected)
            _FormulaLine(
              label: 'Confidence efektif',
              value: 'max(65%, $confidencePercent%) = $effectivePercent%',
            )
          else
            _FormulaLine(
              label: 'Confidence efektif',
              value: '$effectivePercent%',
            ),
          _FormulaLine(
            label: 'Bobot emosi',
            value: '${breakdown.emotion.displayName} = $impact',
          ),
          SizedBox(height: AppSpacing.xs.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.sm.w),
            decoration: BoxDecoration(
              color: p.primaryWash,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: p.primarySoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rumus dampak',
                  style: AppTypography.badge.copyWith(color: p.textSecondary),
                ),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  '$impact x ${breakdown.effectiveConfidence.toStringAsFixed(2)} = $weighted -> $sign${breakdown.delta} poin',
                  style: AppTypography.subtitle,
                ),
              ],
            ),
          ),
          if (currentScore != null) ...[
            SizedBox(height: AppSpacing.sm.h),
            _FormulaLine(
              label: 'Estimasi pada skor saat ini',
              value: '$currentScore + ($sign${breakdown.delta})',
            ),
          ],
          SizedBox(height: AppSpacing.xs.h),
          Text(
            'Catatan: hasil koreksi user mengganti emosi yang dipakai. Jika dikoreksi, confidence efektif minimal 65% agar koreksi user tetap berpengaruh pada skor.',
            style: AppTypography.micro.copyWith(
              height: 1.45,
              color: p.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}

class _FormulaLine extends StatelessWidget {
  const _FormulaLine({
    required this.label,
    required this.value,
    this.valueEmojiAsset,
  });

  final String label;
  final String value;

  /// Optional raster emoji rendered before [value].
  final String? valueEmojiAsset;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                height: 1.35,
                color: p.textSecondary,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (valueEmojiAsset != null) ...[
                  EmotionEmoji(asset: valueEmojiAsset!, size: 14),
                  SizedBox(width: AppSpacing.xxs.w),
                ],
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: AppTypography.caption.copyWith(
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: p.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Note ─────────────────────────
class _NoteCard extends StatelessWidget {
  final TextEditingController controller;
  final bool saving;
  final bool savedTick;
  final ValueChanged<String> onChanged;
  final VoidCallback onSave;
  const _NoteCard({
    required this.controller,
    required this.saving,
    required this.savedTick,
    required this.onChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    return SessionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, size: AppSpacing.lg.sp),
              SizedBox(width: AppSpacing.xs.w),
              Text(l10n.sessionNoteTitle, style: AppTypography.bodyStrong),
            ],
          ),
          SizedBox(height: AppSpacing.xs.h),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: l10n.sessionNoteHint,
              hintStyle: AppTypography.caption.copyWith(
                color: p.textSecondary.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: p.surface2,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm.w,
                vertical: AppSpacing.sm.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: p.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: p.primaryFill.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xs.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? SizedBox(
                      width: AppSpacing.sm.sp,
                      height: AppSpacing.sm.sp,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.save_outlined,
                      size: AppSpacing.lg.sp,
                      color: p.primaryText,
                    ),
              label: Text(
                savedTick ? l10n.noteSaved : l10n.saveNote,
                style: AppTypography.label.copyWith(color: p.primaryText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Hotline ─────────────────────────
class _HotlineCard extends StatelessWidget {
  final void Function(String) onCall;
  const _HotlineCard({required this.onCall});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(AppSpacing.card.r),
      decoration: BoxDecoration(
        color: p.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: p.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs.w),
            decoration: BoxDecoration(color: p.warning, shape: BoxShape.circle),
            child: Icon(
              Icons.phone_in_talk_rounded,
              color: p.onPrimary,
              size: AppSpacing.lg.sp,
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.needHelp, style: AppTypography.subtitle),
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  l10n.hotlineDesc,
                  style: AppTypography.caption.copyWith(
                    color: p.textPrimary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: AppSpacing.xs.h),
                Wrap(
                  spacing: AppSpacing.xs.w,
                  children: [
                    _hotline(context, l10n, '119', l10n.emergencyHealthService),
                    _hotline(context, l10n, '119', l10n.mentalHealthService),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hotline(
    BuildContext context,
    AppLocalizations l10n,
    String dial,
    String label,
  ) {
    final p = context.palette;
    return ActionChip(
      onPressed: () => onCall(dial),
      avatar: Icon(Icons.call, size: AppSpacing.sm.sp, color: p.warning),
      label: Text(
        '$dial · $label',
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: p.warning,
        ),
      ),
      backgroundColor: p.surface1,
      side: BorderSide(color: p.warning.withValues(alpha: 0.4)),
    );
  }
}

// ───────────────────────── Weekly chart ─────────────────────────
class _WeeklyChart extends StatelessWidget {
  final Map<EmotionLabelType, int> chart;
  const _WeeklyChart({required this.chart});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final entries = chart.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = entries.isEmpty
        ? 1
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return SessionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.weeklyEmotionDistribution, style: AppTypography.bodyStrong),
          SizedBox(height: AppSpacing.md.h),
          if (entries.isEmpty)
            Text(
              l10n.noDataThisWeek,
              style: AppTypography.caption.copyWith(color: p.textSecondary),
            )
          else
            ...entries.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
                child: Row(
                  children: [
                    EmotionEmoji(asset: e.key.emojiAsset, size: 14),
                    SizedBox(width: AppSpacing.xs.w),
                    SizedBox(
                      width: AppSpacing.xxl.w,
                      child: Text(
                        e.key.displayName,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: p.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs.w),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: AppRadius.chip,
                        child: LinearProgressIndicator(
                          value: e.value / maxCount,
                          minHeight: AppSpacing.xxs.h,
                          backgroundColor: p.surface3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            e.key.color,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs.w),
                    SizedBox(
                      width: AppSpacing.xl.w,
                      child: Text(
                        '${e.value}',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: p.textPrimary,
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
}

// ───────────────────────── Saran tips ─────────────────────────
class _SaranCard extends StatelessWidget {
  final List<String> tips;
  const _SaranCard({required this.tips});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    if (tips.isEmpty) return const SizedBox.shrink();
    return SessionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: p.primaryText,
                size: AppSpacing.lg.sp,
              ),
              SizedBox(width: AppSpacing.xs.w),
              Text(l10n.tipsForYou, style: AppTypography.bodyStrong),
            ],
          ),
          SizedBox(height: AppSpacing.xs.h),
          ...tips.map(
            (t) => Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: AppSpacing.xxs.h),
                    child: Icon(
                      Icons.circle,
                      size: AppSpacing.xxs.sp,
                      color: p.secondaryText,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs.w),
                  Expanded(
                    child: Text(
                      t,
                      style: AppTypography.caption.copyWith(
                        height: 1.45,
                        color: p.textPrimary,
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
}

// ───────────────────────── Teaser ─────────────────────────
class _TeaserCard extends StatelessWidget {
  const _TeaserCard();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    return SessionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.wantFullResults, style: AppTypography.bodyStrong),
          SizedBox(height: AppSpacing.xxs.h),
          Text(
            l10n.loginRegisterForFull,
            style: AppTypography.caption.copyWith(
              height: 1.4,
              color: p.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          SecondaryButton(
            text: l10n.loginRegister,
            icon: Icons.lock_rounded,
            backgroundColor: p.secondarySoft,
            textColor: p.onPrimary,
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
