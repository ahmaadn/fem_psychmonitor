import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/date_utils.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_chip.dart';
import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/tables/app_tables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite/sqflite.dart';

/// Shared "Aku merasa hari ini" bottom sheet. Returns selected emotion or null.
Future<EmotionLabelType?> showTodayMoodSheet(
  BuildContext context, {
  EmotionLabelType? initial,
  String? title,
}) {
  final p = context.palette;
  return showModalBottomSheet<EmotionLabelType>(
    context: context,
    backgroundColor: p.surface1,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
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
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: AppSpacing.md.h),
                  decoration: BoxDecoration(
                    color: sheetP.divider,
                    borderRadius: AppRadius.chip,
                  ),
                ),
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

Future<void> persistDailyMood({
  required String userId,
  required EmotionLabelType emotion,
  DateTime? day,
}) async {
  final db = await DatabaseHelper.instance.database;
  final now = DateTime.now().millisecondsSinceEpoch;
  final key = dateKeyLocal(day ?? DateTime.now());
  await db.insert(
    AppTables.dailyMoods,
    {
      'user_id': userId,
      'date': key,
      'emotion': emotion.name,
      'created_at': now,
      'updated_at': now,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<EmotionLabelType?> loadDailyMood(String userId, {DateTime? day}) async {
  try {
    final db = await DatabaseHelper.instance.database;
    final key = dateKeyLocal(day ?? DateTime.now());
    final rows = await db.query(
      AppTables.dailyMoods,
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final name = rows.first['emotion'] as String?;
    if (name == null) return null;
    return EmotionLabelType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => EmotionLabelType.neutral,
    );
  } catch (_) {
    return null;
  }
}
