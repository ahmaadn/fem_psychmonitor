import 'dart:async';

import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/widgets/control_action.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/widgets/custom_badge.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSession();
    });
  }

  Future<void> _startSession() async {
    final detector = context.read<EmotionDetector>();
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
    await detector.stopDetection();
    detector.clearTimeline();
    if (!mounted) return;
    if (context.canPop()) context.pop();
  }

  Future<void> _finishSession() async {
    final detector = context.read<EmotionDetector>();
    await detector.stopDetection();
    if (!mounted) return;
    context.goNamed(RouteNames.recordingProcessing);
  }

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
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
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'RECORDING', // Kosongkan title tengah
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    Text(
                      'Speak your mind',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w800,
                        color:
                            AppColors.primary, // Menggunakan warna utama (Biru)
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Capture your thoughts. This recording will be processed into private insights within your digital sanctuary.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15.sp,
                        color: AppColors.onSurface,
                        height: 1.5,
                      ),
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
                          _formatDuration(_elapsed),
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
                    _buildWaveformVisualizer(detector),
                    SizedBox(height: 48.h),
                    Center(
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
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF785800),
                              shape: BoxShape.circle,
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
                          label: 'Done',
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
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: AppColors
                            .surfaceContainerLow, // Off-white / Slate 50
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: AppColors.surfaceContainerHighest,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 16.sp,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'PRIVACY CHECK',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Your voice is encrypted. Only your insights are shared with your future self.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 13.sp,
                                  color: AppColors.onSurface,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
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

  Widget _buildWaveformVisualizer(EmotionDetector detector) {
    final probs = detector.latest?.allProbs;
    final List<double> heights = probs == null || probs.isEmpty
        ? [
            30,
            45,
            60,
            40,
            80,
            50,
            90,
            70,
            100,
            60,
            40,
            85,
            75,
            45,
            95,
            60,
            80,
            50,
            35,
          ]
        : List<double>.generate(19, (i) {
            final value = probs[i % probs.length].clamp(0.0, 1.0);
            return 25 + (value * 95);
          });

    return SizedBox(
      height: 120.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: heights.map((height) {
          return Container(
            width: 4.w,
            height: height.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          );
        }).toList(),
      ),
    );
  }
}
