import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Cincin progres melingkar (donut) berbasis [fl_chart].
///
/// Menggantikan `CircularPercentIndicator` dari package `percent_indicator`
/// agar dependency tersebut dapat dihapus. Menampilkan ring melingkar yang
/// terisi secara animatif dari 0 sampai [percent], dengan widget [center]
/// berada di tengah ring.
class CircularProgressRing extends StatefulWidget {
  const CircularProgressRing({
    super.key,
    required this.percent,
    required this.progressColor,
    this.backgroundColor,
    this.radius = 72,
    this.lineWidth = 10,
    this.duration = const Duration(milliseconds: 1200),
    this.center,
  });

  /// Nilai progres (0.0 - 1.0); akan dijepit ke rentang tersebut.
  final double percent;

  /// Warna busur progres.
  final Color progressColor;

  /// Warna latar ring (sisa busur yang belum terisi).
  final Color? backgroundColor;

  /// Jari-jari ring.
  final double radius;

  /// Lebar busur ring.
  final double lineWidth;

  /// Durasi animasi pengisian dari 0 ke [percent].
  final Duration duration;

  /// Widget yang ditampilkan di tengah ring.
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
    final clamped = widget.percent.clamp(0.0, 1.0);
    final size = widget.radius * 2;
    final centerSpace = (widget.radius - widget.lineWidth)
        .clamp(0.0, widget.radius);

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
                  // Mulai dari atas (jarum jam pukul 12).
                  startDegreeOffset: 270,
                  sectionsSpace: 0,
                  centerSpaceRadius: centerSpace,
                  sections: [
                    PieChartSectionData(
                      value: animated,
                      color: widget.progressColor,
                      radius: widget.lineWidth,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: 1 - animated,
                      color: widget.backgroundColor ?? Colors.transparent,
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
