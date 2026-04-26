import 'dart:async';

import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/utils/formater_utils.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/widgets/control_action.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/widgets/custom_badge.dart';
import 'package:fem_psychmonitor/widgets/info_card.dart';
import 'package:fem_psychmonitor/widgets/page_header.dart';
import 'package:fem_psychmonitor/widgets/wave_form_visualizer.dart';
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
      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });
  }

  Future<void> _discardSession() async {
    final detector = context.read<EmotionDetector>();
    _ticker?.cancel();
    await detector.stopDetection();
    detector.clearTimeline();
    if (!mounted) return;
    if (context.canPop()) context.pop();
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

    return Scaffold(
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
                    SizedBox(height: 48.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Live Session Badge
                        CustomBadge(
                          text: 'LIVE SESSION',
                          backgroundColor: const Color(0xFFFFE5E5), // Red 100
                          textColor: const Color(0xFFFF4D4D), // Red 600
                          icon: Icons.circle,
                          iconColor: const Color(0xFFFF4D4D), // Red 600
                        ),
                        // Timer
                        Text(
                          formatDuration(_elapsed),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 48.h),
                    WaveFormVisualizer(detector: detector),
                    SizedBox(height: 48.h),
                    Center(
                      child: GestureDetector(
                        onTap: detector.isDetecting
                            ? _finishSession
                            : _startSession,
                        child: Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: .circular(AppRadius.xxl),
                          ),
                          padding: EdgeInsets.all(14.w),
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            child: Icon(
                              detector.isDetecting
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              color: Color(0xFF785800),
                              size: 42.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 48.h),
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
                          icon: Icons.pause_rounded,
                          label: 'Pause',
                          bgColor: const Color(0xFFF1F5F9), // Slate 100
                          iconColor: AppColors.primary.withAlpha(153),
                          onTap: () {},
                        ),
                        ControlAction(
                          icon: detector.isDetecting
                              ? Icons.check_rounded
                              : Icons.play_arrow_rounded,
                          label: detector.isDetecting ? 'Done' : 'Start',
                          bgColor: AppColors.primary,
                          iconColor: Colors.white,
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
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.red),
                      ),
                    ],
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
    );
  }
}
