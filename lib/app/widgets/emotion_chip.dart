import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Emotion badge — pill, label typography uppercase, base@12–15% fill.
class EmotionBadge extends StatelessWidget {
  const EmotionBadge({
    super.key,
    required this.emotion,
    this.showEmoji = true,
    this.compact = false,
  });

  final EmotionLabelType emotion;
  final bool showEmoji;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final base = p.emotionBase(emotion);
    final onE = p.emotionText(emotion);
    final label = emotion.label.toUpperCase();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs.w : AppSpacing.sm.w,
        vertical: compact ? AppSpacing.xxs.h : AppSpacing.xs.h,
      ),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.14),
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showEmoji) ...[
            Text(emotion.emoji, style: TextStyle(fontSize: 12.sp)),
            SizedBox(width: AppSpacing.xxs.w),
          ],
          Text(
            label,
            style: AppTypography.label.copyWith(color: onE),
          ),
        ],
      ),
    );
  }
}

/// Selectable emotion chip for pickers (emotion palette when selected).
class EmotionChip extends StatefulWidget {
  const EmotionChip({
    super.key,
    required this.emotion,
    required this.selected,
    required this.onSelected,
    this.showLabel = true,
  });

  final EmotionLabelType emotion;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final bool showLabel;

  @override
  State<EmotionChip> createState() => _EmotionChipState();
}

class _EmotionChipState extends State<EmotionChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final selected = widget.selected;
    final base = p.emotionBase(widget.emotion);
    final onE = p.emotionText(widget.emotion);
    final pressed = _pressed && !selected;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onSelected(!selected);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: AppSpacing.xs.h,
          ),
          decoration: BoxDecoration(
            color: selected
                ? base.withValues(alpha: 0.15)
                : pressed
                    ? p.surface3
                    : p.surface2,
            borderRadius: AppRadius.chip,
            border: Border.all(
              color: selected ? base.withValues(alpha: 0.45) : p.divider,
              width: AppBorder.thin,
            ),
          ),
          child: Text(
            widget.showLabel
                ? '${widget.emotion.emoji} ${widget.emotion.label}'
                : widget.emotion.emoji,
            style: AppTypography.label.copyWith(
              color: selected ? onE : p.textPrimary,
              letterSpacing: selected ? 0.4 : 0.1,
            ),
          ),
        ),
      ),
    );
  }
}
