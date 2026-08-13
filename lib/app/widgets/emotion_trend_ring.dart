import 'dart:math' as math;

import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Emotion trend ring — 96dp, surface-3 track, dominant or multi-segment.
class EmotionTrendRing extends StatelessWidget {
  const EmotionTrendRing({
    super.key,
    required this.dominant,
    this.confidence = 0,
    this.segments,
    this.size,
    this.strokeWidth,
    this.showCenter = true,
  });

  final EmotionLabelType dominant;
  final double confidence;

  /// Optional multi-emotion weights (values sum need not be 1; normalized).
  final Map<EmotionLabelType, double>? segments;
  final double? size;
  final double? strokeWidth;
  final bool showCenter;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final dim = (size ?? 96).r;
    final stroke = (strokeWidth ?? 4).r;
    final onE = p.emotionText(dominant);

    final map = segments;
    final useMulti = map != null &&
        map.values.where((v) => v > 0).length > 1;

    return SizedBox(
      width: dim,
      height: dim,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(dim, dim),
            painter: _RingPainter(
              trackColor: p.surface3,
              stroke: stroke,
              dominantColor: p.emotionBase(dominant),
              progress: confidence.clamp(0.0, 1.0),
              segments: useMulti
                  ? {
                      for (final e in EmotionLabelType.values)
                        if ((map[e] ?? 0) > 0) e: map[e]!,
                    }
                  : null,
              emotionColors: p.emotion,
            ),
          ),
          if (showCenter)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dominant.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle.copyWith(
                      color: p.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    '${(confidence * 100).round()}%',
                    style: AppTypography.metric.copyWith(
                      color: onE,
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.trackColor,
    required this.stroke,
    required this.dominantColor,
    required this.progress,
    required this.segments,
    required this.emotionColors,
  });

  final Color trackColor;
  final double stroke;
  final Color dominantColor;
  final double progress;
  final Map<EmotionLabelType, double>? segments;
  final Map<EmotionLabelType, Color> emotionColors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - stroke) / 2;
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);

    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;

    if (segments != null && segments!.isNotEmpty) {
      final total = segments!.values.fold<double>(0, (a, b) => a + b);
      if (total <= 0) return;
      var angle = start;
      for (final entry in segments!.entries) {
        final sweep = (entry.value / total) * 2 * math.pi;
        final paint = Paint()
          ..color = emotionColors[entry.key] ?? dominantColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt;
        canvas.drawArc(rect, angle, sweep, false, paint);
        angle += sweep;
      }
      return;
    }

    if (progress <= 0) return;
    final paint = Paint()
      ..color = dominantColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, progress * 2 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.dominantColor != dominantColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.segments != segments;
  }
}
