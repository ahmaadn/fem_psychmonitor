import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            horizontal: AppSpacing.sm.w + 2,
            vertical: AppSpacing.xs.h + 2,
          ),
          decoration: BoxDecoration(
            color: selected
                ? p.primary
                : pressed
                    ? p.strawberry
                    : p.surface,
            borderRadius: AppRadius.chip,
            border: Border.all(
              color: selected
                  ? p.primaryFocus
                  : pressed
                      ? p.primary
                      : p.hairline,
              width: selected || pressed ? AppBorder.thick : AppBorder.thin,
            ),
          ),
          child: Text(
            widget.showLabel
                ? '${widget.emotion.emoji} ${widget.emotion.displayName}'
                : widget.emotion.emoji,
            style: AppTypography.caption.copyWith(
              color: selected ? p.onPrimary : p.ink,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
