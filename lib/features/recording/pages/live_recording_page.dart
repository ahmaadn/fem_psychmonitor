import 'dart:async';

import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/formatter_utils.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_radar_chart.dart';
import 'package:fem_psychmonitor/app/widgets/voiceprint_orb.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/detection/widgets/emotion_badge.dart';
import 'package:fem_psychmonitor/features/home/widgets/info_card.dart';
import 'package:fem_psychmonitor/features/history/widgets/timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LiveRecordingPage extends StatefulWidget {
  const LiveRecordingPage({super.key});

  @override
  State<LiveRecordingPage> createState() => _LiveRecordingPageState();
}

class _LiveRecordingPageState extends State<LiveRecordingPage> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final detector = context.read<EmotionDetector>();
      if (!detector.isDetecting) detector.clearTimeline();
    });
  }

  Future<void> _startSession() async {
    final detector = context.read<EmotionDetector>();
    if (detector.isDetecting) return;
    await detector.startDetection(saveToFile: true);
    if (!mounted) return;
    if (detector.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(detector.error!)));
      return;
    }
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final currentDetector = context.read<EmotionDetector>();
      if (currentDetector.isPaused) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _discardSession() async {
    final l10n = AppLocalizations.of(context)!;
    final detector = context.read<EmotionDetector>();
    if (detector.isDetecting ||
        detector.isPaused ||
        _elapsed > Duration.zero ||
        detector.timeline.isNotEmpty) {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(l10n.discardRecordingTitle),
          content: Text(l10n.discardRecordingMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.discard,
                  style: const TextStyle(
                      color: AppColors.warning, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }
    _ticker?.cancel();
    if (detector.isDetecting || detector.isPaused) {
      await detector.stopDetection();
    }
    detector.clearTimeline();
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(RouteNames.home);
    }
  }

  Future<void> _finishSession() async {
    final detector = context.read<EmotionDetector>();
    _ticker?.cancel();
    await detector.stopDetection();
    if (!mounted) return;
    context.goNamed(RouteNames.recordingProcessing);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detector = context.watch<EmotionDetector>();

    final orbColor = detector.latest?.label.color ?? AppColors.primary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _discardSession();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                Color.lerp(AppColors.background, AppColors.lightStrawberryMilk, 0.45)!,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 8.h),
                      Text(
                        formatDuration(_elapsed),
                        style: AppTypography.tagline,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10n.captureThoughts,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 28.h),
                      VoiceprintOrb(
                        mode: VoiceprintMode.live,
                        color: orbColor,
                        size: 280,
                        amplitudeStream: detector.onAmplitudeChanged,
                      ),
                      SizedBox(height: 24.h),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: detector.latest != null
                            ? EmotionBadge(result: detector.latest!)
                            : SizedBox(
                                key: const ValueKey('hint'),
                                height: 24.h,
                                child: Text(
                                  l10n.startRecordToSee,
                                  style: TextStyle(
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.7),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                      ),
                      if (detector.timeline.isNotEmpty) ...[
                        SizedBox(height: 20.h),
                        EmotionRadarChart(
                          height: 200,
                          title: 'Distribusi live',
                          values: EmotionRadarChart.averageProbsFromResults(
                            detector.timeline.map((e) => e.allProbs),
                          ),
                        ),
                      ],
                      SizedBox(height: 16.h),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: detector.isDetecting
                            ? _VadPill(
                                key: ValueKey(detector.isSpeaking),
                                speaking: detector.isSpeaking,
                                listeningLabel: l10n.vadListening,
                                speechLabel: l10n.vadSpeechDetected,
                              )
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(height: 28.h),
                      _buildPrimaryControl(context, detector),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _GhostAction(
                            label: l10n.discardLabel,
                            icon: Icons.delete_outline_rounded,
                            onTap: _discardSession,
                          ),
                          if (detector.isDetecting) ...[
                            SizedBox(width: 16.w),
                            _GhostAction(
                              label: l10n.doneLabel,
                              icon: Icons.check_rounded,
                              filled: true,
                              onTap: _finishSession,
                            ),
                          ],
                        ],
                      ),
                      if (detector.error != null) ...[
                        SizedBox(height: 16.h),
                        Text(detector.error!,
                            style: TextStyle(
                                fontSize: 12.sp, color: AppColors.warning)),
                      ],
                      if (detector.timeline.isNotEmpty) ...[
                        SizedBox(height: 28.h),
                        const Divider(color: AppColors.outline, height: 1),
                        SizedBox(height: 20.h),
                        ComponentTimeline(
                          timeline: detector.timeline,
                          title: l10n.overallEmotionDistribution,
                          animateFromLastPercent: true,
                          sortByFrequency: false,
                          showAllEmotions: true,
                        ),
                      ],
                      SizedBox(height: 24.h),
                      InfoCard(
                        title: l10n.privacyCheck,
                        message: l10n.privacyCheckMessage,
                        icon: Icons.shield_outlined,
                      ),
                      SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryControl(BuildContext context, EmotionDetector detector) {
    final bool recording = detector.isDetecting && !detector.isPaused;
    final Color color = recording ? AppColors.warning : AppColors.primary;
    final IconData icon = !detector.isDetecting
        ? Icons.mic_rounded
        : detector.isPaused
            ? Icons.play_arrow_rounded
            : Icons.pause_rounded;
    return GestureDetector(
      onTap: () {
        if (!detector.isDetecting) {
          _startSession();
        } else if (detector.isPaused) {
          detector.resumeDetection();
        } else {
          detector.pauseDetection();
        }
      },
      child: Container(
        width: 88.w,
        height: 88.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.30),
              blurRadius: 22,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 36.sp),
      ),
    );
  }
}

class _GhostAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  const _GhostAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = filled ? AppColors.primary : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: filled
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9999.r),
          border: Border.all(
            color: filled
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16.sp),
            SizedBox(width: 6.w),
            Text(label,
                style: TextStyle(
                    fontSize: 12.sp, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _VadPill extends StatelessWidget {
  const _VadPill({
    super.key,
    required this.speaking,
    required this.listeningLabel,
    required this.speechLabel,
  });

  final bool speaking;
  final String listeningLabel;
  final String speechLabel;

  @override
  Widget build(BuildContext context) {
    final label = speaking ? speechLabel : listeningLabel;
    final color = speaking ? AppColors.primary : AppColors.textSecondary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: speaking ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(9999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            speaking
                ? Icons.record_voice_over_rounded
                : Icons.hearing_rounded,
            size: 12.sp,
            color: color,
          ),
          SizedBox(width: 6.w),
          Text(label,
              style: TextStyle(
                  fontSize: 10.sp,
                  color: color,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
