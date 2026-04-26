import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/detection/widgets/emotion_badge.dart';
import 'package:fem_psychmonitor/detection/widgets/timeline_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestDetectionPage extends StatelessWidget {
  const TestDetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final detector = context.watch<EmotionDetector>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deteksi Emosi Suara'),
        actions: [
          if (detector.timeline.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Hapus timeline',
              onPressed: detector.clearTimeline,
            ),
        ],
      ),
      body: !detector.isReady
          ? _buildLoading(detector)
          : _buildMain(context, detector),
    );
  }

  // ── Loading / error ────────────────────────────────────────────────────────
  Widget _buildLoading(EmotionDetector d) {
    if (d.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(d.error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  // ── Main content ───────────────────────────────────────────────────────────
  Widget _buildMain(BuildContext context, EmotionDetector d) {
    return Column(
      children: [
        // ── Live emotion display ─────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: d.latest != null
              ? EmotionBadge(
                  result: d.latest!,
                  key: ValueKey(d.latest!.requestId),
                )
              : const SizedBox(height: 120),
        ),

        // ── Error banner ─────────────────────────────────────────────────
        if (d.error != null)
          Container(
            color: Colors.red.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(d.error!, style: const TextStyle(color: Colors.red)),
          ),

        // ── Timeline chart ───────────────────────────────────────────────
        Expanded(
          child: d.timeline.isEmpty
              ? const Center(
                  child: Text(
                    'Mulai rekam untuk melihat timeline emosi',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : TimelineChart(timeline: d.timeline),
        ),

        // ── Stats bar ────────────────────────────────────────────────────
        if (d.timeline.isNotEmpty) _StatsBar(timeline: d.timeline),

        const SizedBox(height: 16),

        // ── Record button ─────────────────────────────────────────────────
        _RecordButton(detector: d),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Record / stop button ───────────────────────────────────────────────────────
class _RecordButton extends StatelessWidget {
  const _RecordButton({required this.detector});
  final EmotionDetector detector;

  @override
  Widget build(BuildContext context) {
    final bool detecting = detector.isDetecting;
    return GestureDetector(
      onTap: detecting ? detector.stopDetection : detector.startDetection,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: detecting ? Colors.red : Theme.of(context).colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color:
                  (detecting
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary)
                      .withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Icon(
          detecting ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

// ── Emotion frequency stats bar ───────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.timeline});
  final List<EmotionResult> timeline;

  @override
  Widget build(BuildContext context) {
    final counts = <EmotionLabelType, int>{};
    for (final r in timeline) {
      counts[r.label] = (counts[r.label] ?? 0) + 1;
    }
    final total = timeline.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: counts.entries.map((e) {
          final pct = (e.value / total * 100).toStringAsFixed(0);
          return Chip(
            avatar: Text(e.key.emoji),
            label: Text('${e.key.displayName} $pct%'),
            backgroundColor: e.key.color.withValues(alpha: 0.15),
            labelStyle: TextStyle(
              color: e.key.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(color: e.key.color.withValues(alpha: 0.4)),
          );
        }).toList(),
      ),
    );
  }
}
