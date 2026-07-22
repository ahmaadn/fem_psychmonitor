import 'dart:math' as math;
import 'dart:async';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A circular, layered "voiceprint" composed of soft radial bars that breathe
/// at a calm cadence and can tint to any emotion color. It is the visual image
/// of voice: the recording moment, the result hero, and the processing pulse.
///
/// Modes:
/// - `VoiceprintMode.idle` — slow ambient breathing in the primary sage,
///   used on Home as the calm hero before any recording.
/// - `VoiceprintMode.live` — reacts to an amplitude stream while recording;
///   bars scale with incoming loudness.
/// - `VoiceprintMode.static` — renders a frozen ring of bars; used for the
///   result screen where a `confidence` (0..1) controls fill saturation.
class VoiceprintOrb extends StatefulWidget {
  final VoiceprintMode mode;
  final Color? color;
  final double size;

  /// [VoiceprintMode.live]: amplitudes in 0..1 drive the bar heights.
  final Stream<double>? amplitudeStream;

  /// [VoiceprintMode.static]: confidence 0..1 crossfades from muted to vivid.
  final double? confidence;

  /// Optional small ticker label rendered centered (e.g. a percent).
  final String? centerTop;

  /// Optional caption rendered centered beneath [centerTop].
  final String? centerBottom;

  /// Number of radial bars.
  final int barCount;

  const VoiceprintOrb({
    super.key,
    this.mode = VoiceprintMode.idle,
    this.color,
    this.size = 220,
    this.amplitudeStream,
    this.confidence,
    this.centerTop,
    this.centerBottom,
    this.barCount = 28,
  });

  @override
  State<VoiceprintOrb> createState() => _VoiceprintOrbState();
}

enum VoiceprintMode { idle, live, static }

class _VoiceprintOrbState extends State<VoiceprintOrb>
    with TickerProviderStateMixin {
  late final AnimationController _breathe;
  late final Animation<double> _breatheCurve;
  StreamSubscription<double>? _ampSub;
  final List<double> _bars = [];
  double _amp = 0.0;

  @override
  void initState() {
    super.initState();
    _bars.addAll(List.filled(widget.barCount, 0.18));
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
    _breatheCurve = CurvedAnimation(parent: _breathe, curve: Curves.easeInOut);
    _subscribeAmplitude();
  }

  @override
  void didUpdateWidget(covariant VoiceprintOrb old) {
    super.didUpdateWidget(old);
    if (old.amplitudeStream != widget.amplitudeStream) {
      _subscribeAmplitude();
    }
    if (old.barCount != widget.barCount) {
      _bars
        ..clear()
        ..addAll(List.filled(widget.barCount, 0.18));
    }
  }

  void _subscribeAmplitude() {
    _ampSub?.cancel();
    _amp = 0.0;
    final stream = widget.amplitudeStream;
    if (widget.mode == VoiceprintMode.live && stream != null) {
      _ampSub = stream.listen((a) {
        if (!mounted) return;
        _amp = a.clamp(0.0, 1.0);
      });
    }
  }

  @override
  void dispose() {
    _ampSub?.cancel();
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final accent = widget.color ?? p.primary;
    final reduced = MediaQuery.of(context).disableAnimations;
    return SizedBox(
      width: widget.size.w,
      height: widget.size.w,
      child: AnimatedBuilder(
        animation: _breathe,
        builder: (context, _) {
          final double t = reduced ? 0.5 : _breatheCurve.value;
          return CustomPaint(
            painter: _VoiceprintPainter(
              bars: _liveBars(t),
              accent: accent,
              bgAlpha: _bgAlpha(),
              amplitude: _amp,
              confidence: widget.confidence ?? 0.65,
              mode: widget.mode,
            ),
            child: (widget.centerTop != null || widget.centerBottom != null)
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.centerTop != null)
                          Text(
                            widget.centerTop!,
                            style: TextStyle(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                              letterSpacing: -1.0,
                              color: p.ink,
                            ),
                          ),
                        if (widget.centerTop != null &&
                            widget.centerBottom != null)
                          SizedBox(height: 4.h),
                        if (widget.centerBottom != null)
                          Text(
                            widget.centerBottom!,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: p.inkMuted,
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  /// Builds the per-bar intensities. In idle/static modes the bars follow a
  /// smooth wave that breathes with [t]. In live mode the wave is perturbed by
  /// the latest amplitude so the orb visibly reacts to the speaker's voice.
  List<double> _liveBars(double t) {
    final n = _bars.length;
    final out = List<double>.filled(n, 0.0);
    for (int i = 0; i < n; i++) {
      final phase = (i / n) * math.pi * 2;
      final wave = 0.5 + 0.5 * math.sin(phase * 2 + t * math.pi * 2);
      double v = 0.22 + 0.42 * wave;
      if (widget.mode == VoiceprintMode.live) {
        // perturb each bar by its own offset times the live amplitude so it
        // feels like a real voiceprint reacting, not a uniform pulse.
        final barAmt = _amp * (0.6 + 0.4 * math.sin(phase * 3 + t * 8));
        v = math.min(1.0, v + barAmt * 0.8);
      }
      out[i] = v;
    }
    return out;
  }

  double _bgAlpha() {
    switch (widget.mode) {
      case VoiceprintMode.static:
        return 0.06;
      case VoiceprintMode.live:
        return 0.10;
      case VoiceprintMode.idle:
        return 0.07;
    }
  }
}

class _VoiceprintPainter extends CustomPainter {
  final List<double> bars;
  final Color accent;
  final double bgAlpha;
  final double amplitude;
  final double confidence;
  final VoiceprintMode mode;

  _VoiceprintPainter({
    required this.bars,
    required this.accent,
    required this.bgAlpha,
    required this.amplitude,
    required this.confidence,
    required this.mode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final minSide = math.min(size.width, size.height);
    final ringOuter = minSide * 0.46;
    final ringInner = minSide * 0.30;
    final core = minSide * 0.24;

    // Soft halo behind the orb.
    final halo = Paint()
      ..color = accent.withValues(alpha: bgAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center, minSide * 0.5, halo);

    // Radial bars — each rotates around the center. Static mode dims them
    // by (1 - confidence) so a low-confidence result reads as muted.
    final maxLen = ringOuter - ringInner;
    for (int i = 0; i < bars.length; i++) {
      final angle = (i / bars.length) * math.pi * 2 - math.pi / 2;
      final intensity = bars[i];
      final len = maxLen * intensity;
      final r1 = ringInner;
      final r2 = ringInner + len;
      final p1 = Offset(
        center.dx + r1 * math.cos(angle),
        center.dy + r1 * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + r2 * math.cos(angle),
        center.dy + r2 * math.sin(angle),
      );
      final alpha = mode == VoiceprintMode.static
          ? (0.25 + 0.65 * confidence)
          : (0.45 + 0.4 * intensity);
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = accent.withValues(alpha: alpha)
          ..strokeWidth = size.width * 0.012
          ..strokeCap = StrokeCap.round,
      );
    }

    // Inner dashed ring for the result mode (a quiet confidence track).
    if (mode == VoiceprintMode.static) {
      final track = Paint()
        ..color = accent.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.014;
      canvas.drawCircle(center, ringInner - maxLen * 0.10, track);

      final sweep = Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.014
        ..strokeCap = StrokeCap.round;
      final rect = Rect.fromCircle(
        center: center,
        radius: ringInner - maxLen * 0.10,
      );
      const start = -math.pi / 2;
      canvas.drawArc(rect, start, math.pi * 2 * confidence, false, sweep);
    }

    // Soft core disc.
    final corePaint = Paint()
      ..color = accent.withValues(
        alpha: mode == VoiceprintMode.live ? 0.18 + amplitude * 0.20 : 0.12,
      );
    canvas.drawCircle(center, core, corePaint);
  }

  @override
  bool shouldRepaint(covariant _VoiceprintPainter old) =>
      old.accent != accent ||
      old.amplitude != amplitude ||
      old.confidence != confidence ||
      old.mode != mode;
}
