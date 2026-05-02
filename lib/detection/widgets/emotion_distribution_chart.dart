import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmotionDistributionChart extends StatelessWidget {
  final EmotionResult result;

  const EmotionDistributionChart({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: Colors.black54, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Distribusi Emosi',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ...EmotionLabelType.values.map((label) {
            final double probability = result.allProbs[label.index];
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  Text(label.emoji, style: TextStyle(fontSize: 20.sp)),
                  SizedBox(width: 12.w),
                  SizedBox(
                    width: 70.w,
                    child: Text(
                      label.displayName,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          height: 8.h,
                          // Menggunakan FractionallySizedBox dalam batasan Stack
                          // Akan otomatis menskala berdasarkan persentase (probability)
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: probability,
                            child: Container(
                              decoration: BoxDecoration(
                                color: label.color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  SizedBox(
                    width: 45.w,
                    child: Text(
                      '${(probability * 100).toStringAsFixed(1)}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
