import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/utils/recommendation_engine.dart';
import 'package:fem_psychmonitor/features/onboarding/models/ocean_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// "Untukmu" / "For you" section header — icon chip + label.
///
/// Shared so Home and the analysis result page present recommendations
/// identically instead of each screen inventing its own tips header.
class ForYouHeader extends StatelessWidget {
  const ForYouHeader({super.key, required this.isEn});

  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: p.iconChipFill(IconChipFamily.secondary),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.auto_awesome_rounded,
            color: p.secondaryText,
            size: 15.sp,
          ),
        ),
        SizedBox(width: AppSpacing.xs.w),
        Text(
          isEn ? 'For you' : 'Untukmu',
          style: AppTypography.bodyStrong.copyWith(color: p.textPrimary),
        ),
      ],
    );
  }
}

/// Recommendation list — skeleton, safety variant, or one card per tip.
///
/// This is the single source of truth for how a [RecommendationResult] is
/// rendered (DESIGN.md §4 icon-chip system).
class RecommendationSection extends StatelessWidget {
  const RecommendationSection({
    super.key,
    required this.saran,
    required this.isEn,
    this.showSkeleton = true,
  });

  final RecommendationResult? saran;
  final bool isEn;

  /// When false a null [saran] renders nothing instead of loading skeletons.
  final bool showSkeleton;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    // Loading state — skeletons matching the real card shape, so the section
    // does not visibly jump in height when the tips land.
    if (saran == null) {
      if (!showSkeleton) return const SizedBox.shrink();
      return Column(
        children: List.generate(3, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md.w),
              decoration: p.card(elevated: true),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: p.surface3,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 9.h,
                          width: 72.w,
                          decoration: BoxDecoration(
                            color: p.surface3,
                            borderRadius: AppRadius.chip,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs.h),
                        Container(
                          height: 11.h,
                          decoration: BoxDecoration(
                            color: p.surface3,
                            borderRadius: AppRadius.chip,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxs.h),
                        FractionallySizedBox(
                          widthFactor: i.isEven ? 0.62 : 0.45,
                          child: Container(
                            height: 11.h,
                            decoration: BoxDecoration(
                              color: p.surface3,
                              borderRadius: AppRadius.chip,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    }

    if (saran!.items.isEmpty) return const SizedBox.shrink();

    if (saran!.safetyTriggered) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.md.w),
        decoration: p.card(
          color: p.warning.withValues(alpha: p.isDark ? 0.16 : 0.10),
          borderColor: p.warning.withValues(alpha: 0.40),
          elevated: true,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: p.iconChipFill(IconChipFamily.warning),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.favorite_rounded,
                    // text-safe step, never the raw base as a glyph color
                    color: p.warningText,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: Text(
                    isEn
                        ? 'You matter — support is here'
                        : 'Kamu berharga — dukungan ada',
                    style: AppTypography.bodyStrong.copyWith(
                      color: p.warningText,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm.h),
            ...saran!.items.map(
              (i) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: BoxDecoration(
                          color: p.warningText,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs.w),
                    Expanded(
                      child: Text(
                        i.text,
                        style: AppTypography.body.copyWith(
                          color: p.textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Normal recommendations — one card per tip.
    // Chip family/icon are derived from the tip's OCEAN trait (SaranItem.trait),
    // not the list index, so the same trait always reads the same way and the
    // list draws from several color families (DESIGN.md §4 icon-chip system).
    return Column(
      children: saran!.items.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
          child: RecommendationCard(item: item, isEn: isEn),
        );
      }).toList(),
    );
  }
}

/// Single tip card — icon chip keyed to the tip's OCEAN trait + tip text.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.item,
    required this.isEn,
  });

  final SaranItem item;
  final bool isEn;

  /// Trait → icon-chip family. Deliberately spans several families so a list of
  /// tips never renders as one repeated brand color (DESIGN.md §4).
  IconChipFamily get _family => switch (item.trait) {
    OceanTrait.o => IconChipFamily.info, // curiosity / exploration
    OceanTrait.c => IconChipFamily.success, // routine / follow-through
    OceanTrait.e => IconChipFamily.primary, // social energy
    OceanTrait.a => IconChipFamily.secondary, // connection / warmth
    OceanTrait.n => IconChipFamily.warning, // emotional regulation
    null => IconChipFamily.secondary, // neutral default tips
  };

  IconData get _icon => switch (item.trait) {
    OceanTrait.o => Icons.explore_rounded,
    OceanTrait.c => Icons.task_alt_rounded,
    OceanTrait.e => Icons.groups_rounded,
    OceanTrait.a => Icons.volunteer_activism_rounded,
    OceanTrait.n => Icons.self_improvement_rounded,
    null => Icons.spa_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final family = _family;
    final trait = item.trait;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: p.card(elevated: true),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon chip — base at 12–15% fill, glyph in the text-safe step
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: p.iconChipFill(family),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            alignment: Alignment.center,
            child: Icon(_icon, color: p.iconChipIcon(family), size: 20.sp),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (trait != null) ...[
                  Text(
                    trait.label(isEn).toUpperCase(),
                    style: AppTypography.label.copyWith(
                      color: p.iconChipIcon(family),
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs.h),
                ],
                Text(
                  item.text,
                  style: AppTypography.body.copyWith(
                    color: p.textPrimary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
