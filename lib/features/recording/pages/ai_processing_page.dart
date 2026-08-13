import 'package:fem_psychmonitor/app/utils/fs_support.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/voiceprint_orb.dart';
import 'package:fem_psychmonitor/data/models/detection_result_model.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/detection_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/profile_viewmodel.dart';
import 'package:fem_psychmonitor/app/utils/date_utils.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/mental_health_score.dart';
import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:fem_psychmonitor/data/repositories/score_log_repository.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AiProcessingPage extends StatefulWidget {
  const AiProcessingPage({super.key, this.uploadedAudioPath});
  final String? uploadedAudioPath;

  @override
  State<AiProcessingPage> createState() => _AiProcessingPageState();
}

class _AiProcessingPageState extends State<AiProcessingPage> {
  String? _processingError;
  bool _noSpeech = false;
  static const Duration _minimumLoadingDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _process());
  }

  Future<void> _process() async {
    final detector = context.read<EmotionDetector>();
    final startedAt = DateTime.now();
    try {
      if (widget.uploadedAudioPath != null &&
          widget.uploadedAudioPath!.trim().isNotEmpty) {
        await detector.detectFromAudioFile(widget.uploadedAudioPath!);
      } else if (detector.isDetecting) {
        await detector.stopDetection();
      }
      await _waitMinimumLoading(startedAt);
      if (!mounted) return;
      if (detector.error != null) {
        setState(() => _processingError = detector.error);
        return;
      }

      if (detector.timeline.isEmpty) {
        await _cleanupTempAudio(widget.uploadedAudioPath);
        if (widget.uploadedAudioPath == null) {
          await _cleanupTempAudio(detector.lastRecordingPath);
        }
        setState(() => _noSpeech = true);
        return;
      }

      final authVm = context.read<AuthViewModel>();
      final detectionVm = context.read<DetectionViewModel>();
      final bool isAuthenticated = await _isAuthenticated();
      if (!mounted) return;

      if (isAuthenticated && authVm.currentUser != null) {
        final sessionId = 'sess_${DateTime.now().millisecondsSinceEpoch}';
        final results = <DetectionResultModel>[];
        final timeline = detector.timeline;
        for (int i = 0; i < timeline.length; i++) {
          final r = timeline[i];
          results.add(
            DetectionResultModel.fromEmotionResult(
              r,
              id: '${sessionId}_result_$i',
              sessionId: sessionId,
            ),
          );
        }

        final dominant = dominantFromResults(timeline);
        final selfReport = await _loadTodayMood(authVm.currentUser!.id);

        final session = DetectionSessionModel(
          id: sessionId,
          userId: authVm.currentUser!.id,
          startedAt: startedAt,
          stoppedAt: DateTime.now(),
          sourceType: widget.uploadedAudioPath != null
              ? DetectionSourceType.upload
              : DetectionSourceType.live,
          audioFilePath: widget.uploadedAudioPath,
          dominantEmotion: dominant.emotion,
          dominantConfidence: dominant.confidence,
          results: results,
          selfReportEmotion: selfReport,
        );

        await detectionVm.saveCurrentSession(session);
        await _applyMentalHealthImpact(session);

        await _cleanupTempAudio(widget.uploadedAudioPath);
        if (widget.uploadedAudioPath == null) {
          await _cleanupTempAudio(detector.lastRecordingPath);
        }

        if (!mounted) return;
        context.goNamed(RouteNames.analysisResult);
      } else {
        context.goNamed(RouteNames.analysisResultTeaser);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _processingError = '$e');
    }
  }

  Future<void> _waitMinimumLoading(DateTime startedAt) async {
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _minimumLoadingDuration - elapsed;
    if (remaining > Duration.zero) await Future.delayed(remaining);
  }

  Future<bool> _isAuthenticated() async {
    return context.read<AuthViewModel>().isAuthenticated;
  }

  Future<EmotionLabelType?> _loadTodayMood(String userId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final today = dateKeyLocal(DateTime.now());
      final rows = await db.query(
        AppTables.dailyMoods,
        where: 'user_id = ? AND date = ?',
        whereArgs: [userId, today],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final name = rows.first['emotion'] as String?;
      if (name == null) return null;
      return EmotionLabelType.values.firstWhere(
        (e) => e.name == name,
        orElse: () => EmotionLabelType.neutral,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _applyMentalHealthImpact(DetectionSessionModel session) async {
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
      session: session,
    );
    final classKey = psychClassKeyForScore(updatedScore);

    await profileVm.updateProfile(
      user.copyWith(psychScore: updatedScore, psychClass: classKey),
      l10n,
    );
    await ScoreLogRepository().append(
      userId: user.id,
      score: updatedScore,
      reason: 'session_create',
    );
  }

  Future<void> _cleanupTempAudio(String? path) async {
    await deleteLocalPath(path);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
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
            context.goNamed(RouteNames.home);
          },
        ),
        title: Text(
          l10n.analysis,
          style: AppTypography.label.copyWith(color: p.textSecondary),
        ),
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(color: p.canvas),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pageX.w,
                vertical: AppSpacing.xl.h,
              ),
              child: _noSpeech
                  ? _buildNoSpeechState(context, l10n)
                  : _buildProcessingState(context, l10n),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingState(BuildContext context, AppLocalizations l10n) {
    final p = context.palette;
    final err = _processingError;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VoiceprintOrb(
          mode: VoiceprintMode.idle,
          color: err == null ? p.primaryFill : p.warning,
          size: 240,
        ),
        SizedBox(height: AppSpacing.xxl.h + 8.h),
        Text(
          l10n.analyzingEmotions,
          style: AppTypography.display.copyWith(color: p.textPrimary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          err ?? l10n.compilingInsights,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: err == null ? p.textSecondary : p.warningText,
          ),
        ),
      ],
    );
  }

  Widget _buildNoSpeechState(BuildContext context, AppLocalizations l10n) {
    final p = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VoiceprintOrb(
          mode: VoiceprintMode.static,
          color: p.primaryFill,
          size: 200,
          confidence: 0.18,
        ),
        SizedBox(height: AppSpacing.xxl.h),
        Text(
          l10n.noSpeechDetected,
          style: AppTypography.title.copyWith(color: p.textPrimary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm.h),
        SizedBox(
          width: 280.w,
          child: Text(
            l10n.noSpeechDetectedHint,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: p.textSecondary),
          ),
        ),
        SizedBox(height: AppSpacing.xxl.h),
        PrimaryButton(
          text: l10n.tryRecordAgain,
          prefixIcon: Icons.mic_rounded,
          onPressed: () => context.goNamed(RouteNames.liveRecording),
        ),
      ],
    );
  }
}
