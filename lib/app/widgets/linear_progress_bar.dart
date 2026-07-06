import 'package:flutter/material.dart';

/// Batang progres horizontal yang terisi secara animatif.
///
/// Pengganti `LinearPercentIndicator` dari package `percent_indicator` agar
/// dependency tersebut dapat dihapus. Mengisi dari kiri ke kanan dengan sudut
/// membulat penuh (rounded). Saat [percent] berubah, batang akan beranimasi
/// dari nilai sebelumnya (atau dari 0 bila [animateFromLastPercent] false).
class LinearProgressBar extends StatefulWidget {
  const LinearProgressBar({
    super.key,
    required this.percent,
    required this.progressColor,
    this.backgroundColor,
    this.lineHeight = 8,
    this.duration = const Duration(milliseconds: 1000),
    this.barRadius = const Radius.circular(9999),
    this.animateFromLastPercent = true,
  });

  /// Nilai progres (0.0 - 1.0); akan dijepit ke rentang tersebut.
  final double percent;

  /// Warna batang progres yang terisi.
  final Color progressColor;

  /// Warna latar (track) di belakang batang.
  final Color? backgroundColor;

  /// Tinggi batang.
  final double lineHeight;

  /// Durasi animasi pengisian.
  final Duration duration;

  /// Radius sudut membulat batang.
  final Radius barRadius;

  /// Jika true, beranimasi dari nilai sebelumnya; jika false, dari 0.
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
    final clamped = widget.percent.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.all(widget.barRadius),
      child: SizedBox(
        height: widget.lineHeight,
        child: Stack(
          children: [
            // Track latar belakang.
            Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.all(widget.barRadius),
              ),
            ),
            // Batang progres yang terisi animatif.
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
                        color: widget.progressColor,
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
