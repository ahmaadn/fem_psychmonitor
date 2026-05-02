import 'dart:math' as math;
import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _process();
    });
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
        setState(() {
          _processingError = detector.error;
        });
        return;
      }

      // If user is not authenticated, show teaser result and prompt to login/register.
      // TODO: Replace with real auth check when available.
      final bool isAuthenticated = await _isAuthenticated();
      if (isAuthenticated) {
        context.goNamed(RouteNames.analysisResult);
      } else {
        context.goNamed(RouteNames.analysisResultTeaser);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processingError = '$e';
      });
    }
  }

  Future<void> _waitMinimumLoading(DateTime startedAt) async {
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _minimumLoadingDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _isAuthenticated() async {
    // Placeholder: integrate real auth check (SharedPreferences / AuthProvider)
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Analysis', // Kosong
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
              // decoration: BoxDecoration(
              //   color: AppColors.surface,
              //   borderRadius: BorderRadius.circular(AppRadius.xxl),
              //   border: Border.all(color: AppColors.outline),
              // ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      // Soft breathing pulse: 1.0 to 1.15
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
                    'Menganalisis Emosi',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _processingError ?? 'Menyusun wawasan personal Anda...',
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
