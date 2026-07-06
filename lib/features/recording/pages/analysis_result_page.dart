import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/mental_health_score.dart';
import 'package:fem_psychmonitor/app/widgets/voiceprint_orb.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/repositories/recommendation_repository.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/detection_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/profile_viewmodel.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/features/history/widgets/timeline_widget.dart';
import 'package:fem_psychmonitor/features/onboarding/models/psych_model.dart';
import 'package:fem_psychmonitor/features/onboarding/models/saran_model.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
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
  SaranRecommendation? _saran;
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
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: AppColors.textSecondary,
            size: 22.sp,
          ),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8.h),
              _Hero(
                dominant: dominant,
                confidence: dominantConfidence,
                isCorrected: session?.correctedEmotion != null,
                summaryText: summaryText,
              ),
              SizedBox(height: 24.h),
              if (!widget.isTeaser && session != null) ...[
                _CorrectionButton(
                  corrected: session.correctedEmotion != null,
                  onTap: () => _showCorrectionSheet(context, session),
                ),
                SizedBox(height: 16.h),
              ],
              if (!widget.isTeaser &&
                  session != null &&
                  _noteController != null)
                _NoteCard(
                  controller: _noteController!,
                  saving: _isSavingNote,
                  savedTick: _noteSavedTick,
                  onChanged: (_) {
                    if (_noteSavedTick) setState(() => _noteSavedTick = false);
                  },
                  onSave: () => _saveNote(session),
                ),
              if (!widget.isTeaser && session != null) ...[
                SizedBox(height: 16.h),
                _ScoreCalculationCard(session: session),
              ],
              SizedBox(height: 16.h),
              if (showHotline) ...[
                _HotlineCard(onCall: (n) => _launchHotline(context, l10n, n)),
                SizedBox(height: 16.h),
                _WeeklyChart(chart: _weeklyChart),
                SizedBox(height: 16.h),
              ],
              _SectionCard(child: RecordingTimeline(timeline: timeline)),
              SizedBox(height: 16.h),
              ComponentTimeline(
                timeline: timeline,
                title: l10n.emotionComponent,
              ),
              SizedBox(height: 16.h),
              if (_saran != null) ...[
                _SaranCard(tips: _tipsFor(dominant)),
                SizedBox(height: 16.h),
              ],
              SecondaryButton(
                text: l10n.retakeRecording,
                subText: l10n.retakeRecordingSub,
                icon: Icons.replay_rounded,
                onPressed: () => context.goNamed(RouteNames.liveRecording),
              ),
              if (widget.isTeaser) ...[
                SizedBox(height: 16.h),
                const _TeaserCard(),
              ],
              if (!widget.isTeaser) ...[
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    l10n.disclaimer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 48.h),
            ],
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

  Future<void> _showCorrectionSheet(
    BuildContext context,
    DetectionSessionModel session,
  ) async {
    EmotionLabelType? picked =
        session.correctedEmotion ?? session.dominantEmotion;
    final detectionVm = context.read<DetectionViewModel>();

    final result = await showModalBottomSheet<EmotionLabelType>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.outline,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Koreksi Hasil Emosi',
                      style: AppTypography.fraunces(size: 20),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Pilih emosi yang menurutmu paling akurat mendeskripsikan rekaman ini.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: EmotionLabelType.values.map((e) {
                        final selected = e == picked;
                        return ChoiceChip(
                          label: Text('${e.emoji} ${e.displayName}'),
                          selected: selected,
                          onSelected: (_) => setSheetState(() => picked = e),
                          selectedColor: e.color,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20.h),
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
      await detectionVm.correctSession(session.id, result);
      final updated = detectionVm.currentSession?.id == session.id
          ? detectionVm.currentSession
          : detectionVm.viewedSession;
      if (updated != null) {
        await _applyCorrectionMentalHealthImpact(session, updated);
      }
      await _loadExtras();
    }
  }

  Future<void> _applyCorrectionMentalHealthImpact(
    DetectionSessionModel previousSession,
    DetectionSessionModel updatedSession,
  ) async {
    final profileVm = context.read<ProfileViewModel>();
    final authVm = context.read<AuthViewModel>();
    final questionnaireVm = context.read<QuestionnaireViewModel>();
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
    final updatedClass = resolvePsychClassForDisplayScore(
      updatedScore,
      questionnaireVm.psychData,
    );

    await profileVm.updateProfile(
      user.copyWith(
        psychScore: updatedScore,
        psychClass: updatedClass?.classLevel.toString() ?? user.psychClass,
      ),
      l10n,
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.analysisResult,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
              if (isCorrected)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(9999.r),
                  ),
                  child: Text(
                    'Dikoreksi',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          VoiceprintOrb(
            mode: VoiceprintMode.static,
            color: dominant.color,
            size: 220,
            confidence: confidence,
            centerTop: '${(confidence * 100).round()}%',
            centerBottom: l10n.confidence.toUpperCase(),
          ),
          SizedBox(height: 12.h),
          Text(dominant.emoji, style: TextStyle(fontSize: 40.sp, height: 1)),
          SizedBox(height: 6.h),
          Text(
            dominant.displayName,
            style: AppTypography.fraunces(
              size: 30,
              weight: FontWeight.w600,
              color: dominant.color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.dominantEmotionLabel(dominant.displayName),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: 280.w,
            child: Text(
              summaryText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
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
  final VoidCallback onTap;
  const _CorrectionButton({required this.corrected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.edit_outlined, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                corrected ? 'Ubah Koreksi' : 'Koreksi Hasil Emosi',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
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

// ───────────────────────── Section card ─────────────────────────
class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.outline),
      ),
      child: child,
    );
  }
}

class _ScoreCalculationCard extends StatelessWidget {
  const _ScoreCalculationCard({required this.session});

  final DetectionSessionModel session;

  @override
  Widget build(BuildContext context) {
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

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: breakdown.emotion.color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calculate_rounded,
                  color: breakdown.emotion.color,
                  size: 19.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Perhitungan Skor Sesi Ini',
                      style: AppTypography.fraunces(
                        size: 16,
                        weight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Menjelaskan dampak rekaman ini ke skor mental health.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        height: 1.35,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _FormulaLine(
            label: 'Emosi yang dipakai',
            value:
                '${breakdown.emotion.emoji} ${breakdown.emotion.displayName}',
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
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rumus dampak',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '$impact x ${breakdown.effectiveConfidence.toStringAsFixed(2)} = $weighted -> $sign${breakdown.delta} poin',
                  style: AppTypography.fraunces(
                    size: 17,
                    weight: FontWeight.w600,
                    color: breakdown.delta < 0
                        ? AppColors.warning
                        : breakdown.emotion.color,
                  ),
                ),
              ],
            ),
          ),
          if (currentScore != null) ...[
            SizedBox(height: 12.h),
            _FormulaLine(
              label: 'Estimasi pada skor saat ini',
              value: '$currentScore + ($sign${breakdown.delta})',
            ),
          ],
          SizedBox(height: 10.h),
          Text(
            'Catatan: hasil koreksi user mengganti emosi yang dipakai. Jika dikoreksi, confidence efektif minimal 65% agar koreksi user tetap berpengaruh pada skor.',
            style: TextStyle(
              fontSize: 10.sp,
              height: 1.45,
              color: AppColors.textSecondary,
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
  const _FormulaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
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
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: AppColors.secondary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.sessionNoteTitle,
                style: AppTypography.fraunces(size: 16),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: l10n.sessionNoteHint,
              hintStyle: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
              filled: true,
              fillColor: AppColors.inputFill,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? SizedBox(
                      width: 14.sp,
                      height: 14.sp,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.save_outlined,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
              label: Text(
                savedTick ? l10n.noteSaved : l10n.saveNote,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: const BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phone_in_talk_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.needHelp,
                  style: AppTypography.fraunces(
                    size: 16,
                    weight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.hotlineDesc,
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
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
    return ActionChip(
      onPressed: () => onCall(dial),
      avatar: Icon(Icons.call, size: 14.sp, color: AppColors.warning),
      label: Text(
        '$dial · $label',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.warning,
        ),
      ),
      backgroundColor: Colors.white,
      side: BorderSide(color: AppColors.warning.withValues(alpha: 0.4)),
    );
  }
}

// ───────────────────────── Weekly chart ─────────────────────────
class _WeeklyChart extends StatelessWidget {
  final Map<EmotionLabelType, int> chart;
  const _WeeklyChart({required this.chart});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = chart.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = entries.isEmpty
        ? 1
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weeklyEmotionDistribution,
            style: AppTypography.fraunces(size: 16),
          ),
          SizedBox(height: 16.h),
          if (entries.isEmpty)
            Text(
              l10n.noDataThisWeek,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            )
          else
            ...entries.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Text(e.key.emoji, style: TextStyle(fontSize: 14.sp)),
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 56.w,
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
                        borderRadius: BorderRadius.circular(9999.r),
                        child: LinearProgressIndicator(
                          value: e.value / maxCount,
                          minHeight: 7.h,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            e.key.color,
                          ),
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
    final l10n = AppLocalizations.of(context)!;
    if (tips.isEmpty) return const SizedBox.shrink();
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: AppColors.secondary,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(l10n.tipsForYou, style: AppTypography.fraunces(size: 16)),
            ],
          ),
          SizedBox(height: 8.h),
          ...tips.map(
            (t) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Icon(
                      Icons.circle,
                      size: 4.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      t,
                      style: TextStyle(
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
}

// ───────────────────────── Teaser ─────────────────────────
class _TeaserCard extends StatelessWidget {
  const _TeaserCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.wantFullResults, style: AppTypography.fraunces(size: 16)),
          SizedBox(height: 6.h),
          Text(
            l10n.loginRegisterForFull,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
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
