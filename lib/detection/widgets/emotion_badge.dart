import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:flutter/material.dart';

class EmotionBadge extends StatelessWidget {
  final EmotionResult result;

  const EmotionBadge({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: r.label.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: r.label.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Text(r.label.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.label.displayName,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: r.label.color,
                  ),
                ),
                const SizedBox(height: 4),
                // confidence bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: r.confidence,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(r.label.color),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(r.confidence * 100).toStringAsFixed(1)}% keyakinan',
                  style: TextStyle(
                    fontSize: 13,
                    color: r.label.color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // Mini prob bars for all 6 classes
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: EmotionLabelType.values.map((label) {
              final p = r.allProbs[label.index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label.emoji, style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 48,
                      child: LinearProgressIndicator(
                        value: p,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          label.color.withValues(alpha: 0.7),
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
