import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:waveform_flutter/waveform_flutter.dart';

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
  late Stream<Amplitude> _waveformStream;
  StreamController<Amplitude>? _streamController;
  StreamSubscription<double>? _sub;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  @override
  void didUpdateWidget(RealtimeWaveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amplitudeStream != widget.amplitudeStream) {
      _sub?.cancel();
      _initStream();
    }
  }

  void _initStream() {
    _streamController ??= StreamController<Amplitude>.broadcast();

    _sub = widget.amplitudeStream.listen((amp) {
      if (!mounted) return;
      // Amplifikasi nilai agar terlihat lebih dinamis
      // Menggunakan square root untuk mengangkat nilai amplitudo kecil
      double visualAmp = sqrt(amp) * 3.5;

      // Berikan nilai minimum saat hening agar tetap ada animasi riak kecil
      visualAmp = max(0.05, visualAmp.clamp(0.0, 1.0));

      // Mengubah ke format Amplitude dari waveform_flutter
      _streamController?.add(Amplitude(current: visualAmp, max: 1.0));
    });

    _waveformStream = _streamController!.stream;
  }

  @override
  void dispose() {
    _sub?.cancel();
    _streamController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: AnimatedWaveList(
          stream: _waveformStream,
          barBuilder: (animation, amplitude) {
            // Hitung tinggi berdasarkan amplitude (0.05 - 1.0) dikalikan dengan tinggi maksimum container
            final barHeight = max(4.0, amplitude.current * widget.height);

            return SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Center(
                  child: Container(
                    width: 4.0,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: widget.waveColor,
                      borderRadius: BorderRadius.circular(
                        4.0,
                      ), // Rounded corners sesuai desain
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
