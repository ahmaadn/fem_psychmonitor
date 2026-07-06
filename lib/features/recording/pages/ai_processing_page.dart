import 'dart:io';
import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/voiceprint_orb.dart';
import 'package:fem_psychmonitor/data/models/detection_result_model.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/detection_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/profile_viewmodel.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/mental_health_score.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/features/onboarding/models/psych_model.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
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

  Future<void> _applyMentalHealthImpact(DetectionSessionModel session) async {
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
      session: session,
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

  Future<void> _cleanupTempAudio(String? path) async {
    if (path == null || path.trim().isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
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
            context.goNamed(RouteNames.home);
          },
        ),
        title: Text(
          l10n.analysis,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppColors.textSecondary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: _noSpeech
                ? _buildNoSpeechState(context, l10n)
                : _buildProcessingState(context, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingState(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VoiceprintOrb(
          mode: VoiceprintMode.idle,
          color: _processingError == null
              ? AppColors.primary
              : AppColors.warning,
          size: 240,
        ),
        SizedBox(height: 40.h),
        Text(
          l10n.analyzingEmotions,
          style: AppTypography.fraunces(size: 28, weight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Text(
          _processingError ?? l10n.compilingInsights,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.5,
            color: _processingError == null
                ? AppColors.textSecondary
                : AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildNoSpeechState(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VoiceprintOrb(
          mode: VoiceprintMode.static,
          color: AppColors.primary,
          size: 200,
          confidence: 0.18,
        ),
        SizedBox(height: 32.h),
        Text(
          l10n.noSpeechDetected,
          style: AppTypography.fraunces(size: 24, weight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: 280.w,
          child: Text(
            l10n.noSpeechDetectedHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(height: 32.h),
        GestureDetector(
          onTap: () => context.goNamed(RouteNames.liveRecording),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(9999.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic_rounded, color: Colors.white, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  l10n.tryRecordAgain,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
