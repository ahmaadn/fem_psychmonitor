import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PulsingMicButton extends StatefulWidget {
  final VoidCallback onTap;

  const PulsingMicButton({super.key, required this.onTap});

  @override
  State<PulsingMicButton> createState() => _PulsingMicButtonState();
}

class _PulsingMicButtonState extends State<PulsingMicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildPulse({
    required double maxSize,
    required double delay,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double progress = (_controller.value - delay);

        if (progress < 0) {
          progress += 1;
        }

        final scale = 0.6 + (progress * 0.8);
        final opacity = (1 - progress).clamp(0.0, 1.0);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: maxSize,
              height: maxSize,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: SizedBox(
        width: 120.w,
        height: 120.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            buildPulse(
              maxSize: 200.r,
              delay: 1,
              color: AppColors.primary500.withValues(alpha: 0.35),
            ),
            buildPulse(
              maxSize: 150.r,
              delay: 0.5,
              color: AppColors.primary500.withValues(alpha: 0.25),
            ),
            GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 88.r,
                height: 88.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary500,
                  boxShadow: [
                    BoxShadow(
                      color: p.shadowFloating,
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.mic,
                    color: AppColors.onPrimary,
                    size: 36.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
