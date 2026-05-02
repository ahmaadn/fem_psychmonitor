import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:flutter/material.dart';

class EmotionBadge extends StatelessWidget {
  final EmotionResult result;

  const EmotionBadge({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: r.label.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: r.label.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(r.label.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 20),
          Column(
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
              Text(
                '${(r.confidence * 100).toStringAsFixed(1)}% akurasi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: r.label.color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
