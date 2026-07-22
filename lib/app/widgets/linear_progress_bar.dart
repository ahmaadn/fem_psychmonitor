import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:flutter/material.dart';

class LinearProgressBar extends StatefulWidget {
  const LinearProgressBar({
    super.key,
    required this.percent,
    this.progressColor,
    this.backgroundColor,
    this.lineHeight = 8,
    this.duration = const Duration(milliseconds: 1000),
    this.barRadius = const Radius.circular(AppRadius.pill),
    this.animateFromLastPercent = true,
  });

  final double percent;
  final Color? progressColor;
  final Color? backgroundColor;
  final double lineHeight;
  final Duration duration;
  final Radius barRadius;
  final bool animateFromLastPercent;

  @override
  State<LinearProgressBar> createState() => _LinearProgressBarState();
}

class _LinearProgressBarState extends State<LinearProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  double _fromPercent = 0;

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
  void didUpdateWidget(covariant LinearProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent) {
      _fromPercent = widget.animateFromLastPercent ? oldWidget.percent : 0;
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
    final progress = widget.progressColor ?? p.primary;
    final track = widget.backgroundColor ?? p.strawberry;

    return ClipRRect(
      borderRadius: BorderRadius.all(widget.barRadius),
      child: SizedBox(
        height: widget.lineHeight,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: track,
                borderRadius: BorderRadius.all(widget.barRadius),
              ),
            ),
            AnimatedBuilder(
              animation: _curve,
              builder: (context, _) {
                final animated =
                    _fromPercent + (clamped - _fromPercent) * _curve.value;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: animated.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: progress,
                        borderRadius: BorderRadius.all(widget.barRadius),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
