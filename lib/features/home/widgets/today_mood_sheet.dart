import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/widgets/app_bottom_sheet.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_chip.dart';
import 'package:fem_psychmonitor/data/repositories/daily_mood_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared "Aku merasa hari ini" bottom sheet. Returns selected emotion or null.
Future<EmotionLabelType?> showTodayMoodSheet(
  BuildContext context, {
  EmotionLabelType? initial,
  String? title,
}) {
  return showAppBottomSheet<EmotionLabelType>(
    context: context,
    builder: (ctx) {
      EmotionLabelType? sel = initial;
      return StatefulBuilder(
        builder: (ctx, setModal) {
          final sheetP = ctx.palette;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageX.w,
              AppSpacing.md.h,
              AppSpacing.pageX.w,
              AppSpacing.xl.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppSheetHandle(),
                SizedBox(height: AppSpacing.md.h),
                Text(
                  title ?? 'Aku merasa hari ini',
                  style: AppTypography.subtitle.copyWith(
                    color: sheetP.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: EmotionLabelType.values.map((e) {
                    return EmotionChip(
                      emotion: e,
                      selected: sel == e,
                      onSelected: (_) => setModal(() => sel = e),
                    );
                  }).toList(),
                ),
                SizedBox(height: AppSpacing.lg.h),
                PrimaryButton(
                  text: 'Simpan',
                  isDisabled: sel == null,
                  onPressed: () => Navigator.pop(ctx, sel),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

final _dailyMoodRepository = DailyMoodRepository();

Future<void> persistDailyMood({
  required String userId,
  required EmotionLabelType emotion,
  DateTime? day,
}) {
  return _dailyMoodRepository.save(userId: userId, emotion: emotion, day: day);
}

Future<EmotionLabelType?> loadDailyMood(String userId, {DateTime? day}) {
  return _dailyMoodRepository.load(userId, day: day);
}
