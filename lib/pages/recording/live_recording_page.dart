import 'dart:async';

import 'package:fem_psychmonitor/widgets/realtime_wave_visualizer.dart';
import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/utils/formater_utils.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/detection/widgets/emotion_badge.dart';
import 'package:fem_psychmonitor/widgets/control_action.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/widgets/custom_badge.dart';
import 'package:fem_psychmonitor/widgets/info_card.dart';
import 'package:fem_psychmonitor/widgets/page_header.dart';
import 'package:fem_psychmonitor/widgets/timeline_widget.dart';
import 'package:flutter/material.dart';
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
  }

  Future<void> _startSession() async {
    final detector = context.read<EmotionDetector>();

    if (detector.isDetecting) return;

    await detector.startDetection(saveToFile: true);

    if (!mounted) return;
    if (detector.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(detector.error!)));
      return;
    }

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final currentDetector = context.read<EmotionDetector>();
      if (currentDetector.isPaused) return;
      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });
  }

  Future<void> _discardSession() async {
    final detector = context.read<EmotionDetector>();

    // Tampilkan konfirmasi jika rekaman sudah berjalan atau ada data
    if (detector.isDetecting ||
        detector.isPaused ||
        _elapsed > Duration.zero ||
        detector.timeline.isNotEmpty) {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: const Text('Buang Rekaman?'),
          content: const Text(
            'Semua data suara dan analisis emosi pada sesi ini akan dihapus secara permanen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Buang',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) {
        return; // Batal membuang
      }
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
    final detector = context.watch<EmotionDetector>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _discardSession();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'RECORDING',
          showBackButton: false,
          isScrollable: false,
          leading: IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.primary.withAlpha(153),
            ),
            onPressed: _discardSession,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageHeader(
                        title: 'Speak your mind',
                        subtitle:
                            'Capture your thoughts. This recording will be processed into private insights within your digital sanctuary.',
                      ),
                      SizedBox(height: 24.h),

                      Container(
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomBadge(
                                  text: 'LIVE SESSION',
                                  backgroundColor: const Color(0xFFFFE5E5),
                                  textColor: const Color(0xFFFF4D4D),
                                  icon: Icons.circle,
                                  iconColor: const Color(0xFFFF4D4D),
                                ),
                                Text(
                                  formatDuration(_elapsed),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 32.h),

                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: detector.latest != null
                                  ? EmotionBadge(result: detector.latest!)
                                  : SizedBox(
                                      height: 32.h,
                                      child: Center(
                                        child: Text(
                                          'Mulai rekam untuk melihat emosi',
                                          style: TextStyle(
                                            color: AppColors.textSecondary
                                                .withAlpha(128),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            SizedBox(height: 32.h),

                            RealtimeWaveVisualizer(
                              amplitudeStream: detector.onAmplitudeChanged,
                              waveColor: AppColors.primary,
                              width: MediaQuery.of(context).size.width,
                              height: 100.h,
                            ),

                            SizedBox(height: 48.h),

                            Center(
                              child: GestureDetector(
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
                                  width: 80.w,
                                  height: 80.w,
                                  decoration: BoxDecoration(
                                    color: detector.isDetecting
                                        ? (detector.isPaused
                                              ? AppColors.warning
                                              : AppColors.primary)
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.full,
                                    ),
                                    border: Border.all(
                                      color:
                                          (detector.isDetecting
                                                  ? (detector.isPaused
                                                        ? AppColors.warning
                                                        : AppColors.primary)
                                                  : AppColors.primary)
                                              .withAlpha(51),
                                      width: 8,
                                    ),
                                  ),
                                  child: Icon(
                                    !detector.isDetecting
                                        ? Icons.mic_rounded
                                        : detector.isPaused
                                        ? Icons.play_arrow_rounded
                                        : Icons.pause_rounded,
                                    color: Colors.white,
                                    size: 32.sp,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 32.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ControlAction(
                                  icon: Icons.delete_outline_rounded,
                                  label: 'Discard',
                                  bgColor: const Color(0xFFF1F5F9),
                                  iconColor: AppColors.primary.withAlpha(153),
                                  onTap: _discardSession,
                                ),
                                ControlAction(
                                  icon: detector.isDetecting
                                      ? Icons.check_rounded
                                      : Icons.play_arrow_rounded,
                                  label: detector.isDetecting
                                      ? 'Selesai'
                                      : 'Mulai',
                                  bgColor: AppColors.primary.withAlpha(25),
                                  iconColor: AppColors.primary,
                                  onTap: detector.isDetecting
                                      ? _finishSession
                                      : _startSession,
                                ),
                              ],
                            ),
                            if (detector.error != null) ...[
                              SizedBox(height: 16.h),
                              Text(
                                detector.error!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.red),
                              ),
                            ],
                            if (detector.timeline.isNotEmpty) ...[
                              SizedBox(height: 32.h),
                              const Divider(color: Color(0xFFE2E8F0)),
                              SizedBox(height: 24.h),
                              ComponentTimeline(
                                timeline: detector.timeline,
                                title: 'Distribusi Emosi Keseluruhan',
                                animateFromLastPercent: true,
                                sortByFrequency: false,
                                showAllEmotions: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 48.h),
                      InfoCard(
                        title: 'PRIVACY CHECK',
                        message:
                            'Your voice is encrypted. Only your insights are shared with your future self.',
                        icon: Icons.light_mode_outlined,
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
    );
  }
}
