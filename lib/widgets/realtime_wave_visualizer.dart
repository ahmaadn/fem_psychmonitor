import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class RealtimeWaveVisualizer extends StatefulWidget {
  final Stream<double> amplitudeStream;
  final Color waveColor;
  final double height;
  final double width;

  const RealtimeWaveVisualizer({
    super.key,
    required this.amplitudeStream,
    required this.waveColor,
    required this.height,
    required this.width,
  });

  @override
  State<RealtimeWaveVisualizer> createState() => _RealtimeWaveVisualizerState();
}

class _RealtimeWaveVisualizerState extends State<RealtimeWaveVisualizer> {
  final List<double> _amplitudes = [];
  StreamSubscription<double>? _sub;
  final int _maxBars = 50; // Jumlah maksimum batang gelombang yang ditampilkan

  @override
  void initState() {
    super.initState();
    // Mengisi array awal dengan 0 agar gelombang mulai dari kanan (kosong)
    for (int i = 0; i < _maxBars; i++) {
      _amplitudes.add(0.0);
    }
    
    _sub = widget.amplitudeStream.listen((amp) {
      if (!mounted) return;
      setState(() {
        _amplitudes.add(amp);
        if (_amplitudes.length > _maxBars) {
          _amplitudes.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: _WavePainter(
          amplitudes: _amplitudes,
          waveColor: widget.waveColor,
          maxBars: _maxBars,
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final List<double> amplitudes;
  final Color waveColor;
  final int maxBars;

  _WavePainter({
    required this.amplitudes,
    required this.waveColor,
    required this.maxBars,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    // Menghitung lebar setiap batang berdasarkan lebar layar dan jumlah bar
    final barWidth = size.width / maxBars;
    final spacing = barWidth * 0.3; // Jarak antar batang (30%)
    final actualBarWidth = barWidth - spacing;

    for (int i = 0; i < amplitudes.length; i++) {
      // Amplifikasi nilai agar terlihat lebih dinamis (dengan batasan max 1.0)
      double amp = amplitudes[i] * 3.5; 
      amp = amp.clamp(0.0, 1.0);

      // Ketinggian minimum batang saat hening adalah 4.0
      final barHeight = max(4.0, amp * size.height);
      
      // Menggambar dari kiri ke kanan (amplitudo terakhir ada di paling kanan)
      final x = i * barWidth;
      final y = (size.height - barHeight) / 2; // Memusatkan secara vertikal

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, actualBarWidth, barHeight),
        Radius.circular(actualBarWidth / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return true; // Selalu gambar ulang ketika ada data baru
  }
}
