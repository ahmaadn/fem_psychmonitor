import 'dart:math' as math;
import 'dart:io';
import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/data/models/detection_result_model.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/models/detection_session_model.dart';
import 'package:fem_psychmonitor/data/viewmodels/detection_viewmodel.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/app/widgets/custom_app_bar.dart';
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

class _AiProcessingPageState extends State<AiProcessingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _processingError;
  static const Duration _minimumLoadingDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
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

      final bool isAuthenticated = await _isAuthenticated();
      final authVm = context.read<AuthViewModel>();
      final detectionVm = context.read<DetectionViewModel>();

      if (isAuthenticated && authVm.currentUser != null) {
        // Build and save session. Convert the live EmotionResult timeline
        // into persistable DetectionResultModel rows (US-09/US-15).
        final sessionId = 'sess_${DateTime.now().millisecondsSinceEpoch}';
        final results = <DetectionResultModel>[];
        final timeline = detector.timeline;
        for (int i = 0; i < timeline.length; i++) {
          final r = timeline[i];
          results.add(DetectionResultModel.fromEmotionResult(
            r,
            id: '${sessionId}_result_$i',
            sessionId: sessionId,
          ));
        }

        final session = DetectionSessionModel(
          id: sessionId,
          userId: authVm.currentUser!.id,
          startedAt: startedAt,
          stoppedAt: DateTime.now(),
          sourceType: widget.uploadedAudioPath != null
              ? DetectionSourceType.upload
              : DetectionSourceType.live,
          audioFilePath: widget.uploadedAudioPath,
          dominantEmotion: detector.latest?.label ?? EmotionLabelType.neutral,
          dominantConfidence: detector.latest?.confidence ?? 0.0,
          results: results,
        );

        await detectionVm.saveCurrentSession(session);

        // US-16: delete the temporary uploaded audio file now that the session
        // is persisted (filesystem op, not DB).
        await _cleanupTempAudio(widget.uploadedAudioPath);

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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _isAuthenticated() async {
    return context.read<AuthViewModel>().isAuthenticated;
  }

  /// US-16: remove the temporary uploaded audio file now that the session has
  /// been persisted and the result is about to be shown. Only cleans up files
  /// that live outside the app's managed documents storage (i.e. picked temp
  /// files). Missing files are treated as already cleaned up.
  Future<void> _cleanupTempAudio(String? path) async {
    if (path == null || path.trim().isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort cleanup; must not block the result navigation.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: l10n.analysis,
        showBackButton: false,
        isScrollable: false,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          onPressed: () {
            if (context.canPop()) context.pop();
            context.goNamed(RouteNames.home);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 64.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final double pulseScale =
                          1.0 +
                          0.15 * math.sin(_animationController.value * math.pi);
                      return SizedBox(
                        width: 160.w,
                        height: 160.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: pulseScale * 1.2,
                              child: Container(
                                width: 120.w,
                                height: 120.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.05,
                                  ),
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: pulseScale,
                              child: Container(
                                width: 120.w,
                                height: 120.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 80.w,
                              height: 80.w,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                              child: Icon(
                                Icons.eco_rounded,
                                color: Colors.white,
                                size: 40.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 48.h),
                  Text(
                    l10n.analyzingEmotions,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _processingError ?? l10n.compilingInsights,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp,
                      color: _processingError == null
                          ? AppColors.textSecondary
                          : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
