import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:flutter/material.dart';

class TimelineChart extends StatefulWidget {
  const TimelineChart({super.key, required this.timeline});
  final List<EmotionResult> timeline;

  @override
  State<TimelineChart> createState() => _TimelineChartState();
}

class _TimelineChartState extends State<TimelineChart> {
  final ScrollController _scroll = ScrollController();

  @override
  void didUpdateWidget(TimelineChart old) {
    super.didUpdateWidget(old);
    // Auto-scroll to the end when new data arrives
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeline = widget.timeline;
    const barW = 56.0;
    const barMaxH = 140.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            '${timeline.length} segmen · stride 1.5 s',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: timeline.map((r) {
                final h = (r.confidence * barMaxH).clamp(24.0, barMaxH);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Tooltip(
                    message:
                        '${r.label.displayName} ${(r.confidence * 100).toStringAsFixed(1)}%\n'
                        '${r.startSec.toStringAsFixed(1)}s – ${r.endSec.toStringAsFixed(1)}s',
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // confidence label
                        Text(
                          '${(r.confidence * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // colored bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: barW,
                          height: h,
                          decoration: BoxDecoration(
                            color: r.label.color.withValues(alpha: 0.85),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              r.label.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        // time label
                        Container(
                          width: barW,
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            '${r.startSec.toStringAsFixed(1)}s',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // ── Emotion legend ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Wrap(
            spacing: 10,
            children: EmotionLabelType.values
                .map(
                  (e) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: e.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(e.displayName, style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }
}
