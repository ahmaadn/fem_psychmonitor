import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WaveFormVisualizer extends StatelessWidget {
  const WaveFormVisualizer({super.key, required this.detector});

  final EmotionDetector detector;

  @override
  Widget build(BuildContext context) {
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
