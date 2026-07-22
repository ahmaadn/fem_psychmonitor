import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CircularProgressRing extends StatefulWidget {
  const CircularProgressRing({
    super.key,
    required this.percent,
    this.progressColor,
    this.backgroundColor,
    this.radius = 72,
    this.lineWidth = 10,
    this.duration = const Duration(milliseconds: 1200),
    this.center,
  });

  final double percent;
  final Color? progressColor;
  final Color? backgroundColor;
  final double radius;
  final double lineWidth;
  final Duration duration;
  final Widget? center;

  @override
  State<CircularProgressRing> createState() => _CircularProgressRingState();
}

class _CircularProgressRingState extends State<CircularProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(covariant CircularProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent) {
      _controller.duration = widget.duration;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final clamped = widget.percent.clamp(0.0, 1.0);
    final size = widget.radius * 2;
    final centerSpace =
        (widget.radius - widget.lineWidth).clamp(0.0, widget.radius);
    final progress = widget.progressColor ?? p.primary;
    final track = widget.backgroundColor ?? p.strawberry;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _curve,
            builder: (context, _) {
              final animated = clamped * _curve.value;
              return PieChart(
                PieChartData(
                  startDegreeOffset: 270,
                  sectionsSpace: 0,
                  centerSpaceRadius: centerSpace,
                  sections: [
                    PieChartSectionData(
                      value: animated,
                      color: progress,
                      radius: widget.lineWidth,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: 1 - animated,
                      color: track,
                      radius: widget.lineWidth,
                      showTitle: false,
                    ),
                  ],
                ),
              );
            },
          ),
          if (widget.center != null) Center(child: widget.center),
        ],
      ),
    );
  }
}
