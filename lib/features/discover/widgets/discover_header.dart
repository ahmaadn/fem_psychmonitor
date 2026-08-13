import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Top section of the Discover screen: title, year stepper, and the
/// Calendar / Journal segmented control.
class DiscoverHeader extends StatelessWidget {
  const DiscoverHeader({
    super.key,
    required this.year,
    required this.tabs,
    required this.onPrevYear,
    required this.onNextYear,
  });

  final int year;
  final TabController tabs;
  final VoidCallback onPrevYear;
  final VoidCallback onNextYear;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      // Brand red at the top fading into the page canvas at the bottom, so the
      // header blends into the calendar instead of sitting behind a hard edge.
      // No bottom border: the gradient already resolves to `canvas`, and a
      // divider on top of that reads as a seam.
      // decoration: BoxDecoration(gradient: p.brandFadeGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pageX.w,
                AppSpacing.md.h,
                AppSpacing.pageX.w,
                0,
              ),
              child: Text(
                l10n.discoverTitle,
                style: AppTypography.display.copyWith(color: p.textPrimary),
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            // Year stepper only relevant for the calendar tab.
            AnimatedBuilder(
              animation: tabs,
              builder: (_, _) {
                final isCalendar = tabs.index == 0;
                return AnimatedOpacity(
                  opacity: isCalendar ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageX.w,
                    ),
                    child: Row(
                      children: [
                        _YearChevron(
                          icon: Icons.chevron_left_rounded,
                          semanticLabel: l10n.discoverPrevYear,
                          onTap: onPrevYear,
                        ),
                        SizedBox(width: AppSpacing.xs.w),
                        Text(
                          '$year',
                          style: AppTypography.bodyStrong.copyWith(
                            color: p.primaryText,
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs.w),
                        _YearChevron(
                          icon: Icons.chevron_right_rounded,
                          semanticLabel: l10n.discoverNextYear,
                          onTap: onNextYear,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: AppSpacing.sm.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageX.w),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.xxs.w),
                decoration: BoxDecoration(
                  // The header is a gradient now, so a flat surface-2 track
                  // reads as a muddy patch. A translucent surface-1 keeps the
                  // gradient visible while still separating the track from the
                  // selectedTonal indicator.
                  color: p.surface1.withValues(alpha: p.isDark ? 0.34 : 0.62),
                  // Track radius must match the indicator's, otherwise the
                  // unselected side reads as a square while the selected pill
                  // is fully rounded.
                  borderRadius: AppRadius.chip,
                  border: Border.all(
                    color: p.divider.withValues(alpha: 0.6),
                    width: AppBorder.thin,
                  ),
                ),
                child: TabBar(
                  controller: tabs,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: p.selectedTonal,
                    borderRadius: AppRadius.chip,
                  ),
                  // Keep the ripple inside the same pill shape as the
                  // indicator so taps do not flash a rectangle.
                  splashBorderRadius: AppRadius.chip,
                  overlayColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.pressed)
                        ? p.primaryFill.withValues(alpha: 0.10)
                        : Colors.transparent,
                  ),
                  labelColor: p.onSelectedTonal,
                  unselectedLabelColor: p.textTertiary,
                  labelStyle: AppTypography.label,
                  unselectedLabelStyle: AppTypography.label,
                  tabs: [
                    Tab(text: l10n.discoverCalendarTab),
                    Tab(text: l10n.discoverJournalTab),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
          ],
        ),
      ),
    );
  }
}

class _YearChevron extends StatelessWidget {
  const _YearChevron({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.xxs.w),
          decoration: BoxDecoration(
            color: p.primaryFill.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.sm.r),
          ),
          child: Icon(icon, color: p.primaryText, size: 16.sp),
        ),
      ),
    );
  }
}
