import 'dart:math' as math;
import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
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

    try {
      if (widget.uploadedAudioPath != null &&
          widget.uploadedAudioPath!.trim().isNotEmpty) {
        await detector.detectFromAudioFile(widget.uploadedAudioPath!);
      } else if (detector.isDetecting) {
        await detector.stopDetection();
      }

      if (!mounted) return;

      if (detector.error != null) {
        setState(() {
          _processingError = detector.error;
        });
        return;
      }

      context.goNamed(RouteNames.analysisResult);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processingError = '$e';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
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
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        // Hitung skala pulse menggunakan Sinus (0.98 hingga 1.02)
                        final double pulseScale =
                            1.0 +
                            0.02 *
                                math.sin(
                                  _animationController.value * 2 * math.pi * 2,
                                );

                        return SizedBox(
                          width: 240.w,
                          height: 240.w,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.rotate(
                                angle: _animationController.value * 2 * math.pi,
                                child: CustomPaint(
                                  size: Size(240.w, 240.w),
                                  painter: _SegmentedRingPainter(
                                    color: AppColors.tertiary.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                              ),

                              Transform.scale(
                                scale: pulseScale,
                                child: Container(
                                  width: 170.w,
                                  height: 170.w,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        // Color(0xFF26A8FF), // Biru agak terang
                                        AppColors.primary, // Biru Trust
                                        AppColors
                                            .primaryContainer, // Trust Blue
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),

                                  child: Stack(
                                    children: [
                                      Positioned(
                                        right: 32.w,
                                        top: 60.w,
                                        child: Icon(
                                          Icons.auto_awesome_rounded,
                                          color: Colors.white,
                                          size: 36.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 64.h),

                    Text(
                      'Processing Audio',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      _processingError ?? 'Analyzing your audio data...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16.sp,
                        color: _processingError == null
                            ? AppColors.onSurface
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 12.h),

                    Text(
                      'Please wait while we prepare your insights.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSecondaryFixed,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 48.h),
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

// ==========================================
// CUSTOM PAINTER: Garis Lingkaran Putus-putus
// ==========================================
class _SegmentedRingPainter extends CustomPainter {
  final Color color;

  _SegmentedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round; // Ujung garis dibuat tumpul/membulat

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 2; // Kurangi sedikit agar tidak terpotong

    // Membuat 4 segmen busur garis (arc) dengan jarak kosong (gap) di antaranya
    const int segments = 4;
    const double sweepAngle =
        (math.pi * 2) /
        segments *
        0.7; // Panjang garis 70% dari ruang yang tersedia
    const double gapAngle =
        (math.pi * 2) /
        segments *
        0.3; // Gap kosong 30% dari ruang yang tersedia

    double startAngle = 0.0;

    for (int i = 0; i < segments; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      // Pindahkan sudut mulai untuk segmen berikutnya
      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedRingPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
