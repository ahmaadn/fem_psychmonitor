import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom sheet panduan penggunaan aplikasi.
/// Panggil dengan: `AppGuideSheet.show(context);`
class AppGuideSheet extends StatefulWidget {
  const AppGuideSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AppGuideSheet(),
    );
  }

  @override
  State<AppGuideSheet> createState() => _AppGuideSheetState();
}

class _AppGuideSheetState extends State<AppGuideSheet> {
  int _selectedStep = 0;

  List<_GuideStep> _buildSteps(AppLocalizations l10n) => [
    _GuideStep(
      icon: Icons.mic_rounded,
      iconColor: Color(0xFF1B6B51),
      iconBg: Color(0xFFD1FAE5),
      title: l10n.recordVoiceGuide,
      description: l10n.recordVoiceGuideDesc,
    ),
    _GuideStep(
      icon: Icons.insights_rounded,
      iconColor: Color(0xFF6D5096),
      iconBg: Color(0xFFEDDCFF),
      title: l10n.viewEmotionInsights,
      description: l10n.viewInsightsDesc,
    ),
    _GuideStep(
      icon: Icons.calendar_month_rounded,
      iconColor: Color(0xFF2563EB),
      iconBg: Color(0xFFDBEAFE),
      title: l10n.monitorCycle,
      description: l10n.monitorCycleDesc,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = _buildSteps(l10n);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          child: Column(
            children: [
              // Drag Handle
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.md.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg.w,
                  AppSpacing.lg.h,
                  AppSpacing.lg.w,
                  AppSpacing.sm.h,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.tertiary,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.appGuideTitle, style: AppTypography.h2),
                          Text(
                            l10n.stepsToStart(steps.length),
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),
              // Step Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                child: Row(
                  children: List.generate(steps.length, (i) {
                    final isSelected = _selectedStep == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedStep = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: AppSpacing.sm.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.tertiary
                              : AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: AppTypography.label.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              Divider(height: 1, thickness: 1, color: AppColors.outline),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(AppSpacing.lg.w),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _StepContent(
                      key: ValueKey(_selectedStep),
                      step: steps[_selectedStep],
                      index: _selectedStep,
                      totalSteps: steps.length,
                    ),
                  ),
                ),
              ),
              // Navigation
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg.w,
                  AppSpacing.sm.h,
                  AppSpacing.lg.w,
                  AppSpacing.lg.h + MediaQuery.of(context).padding.bottom,
                ),
                child: Row(
                  children: [
                    if (_selectedStep > 0) ...[
                      Expanded(
                        child: SecondaryButton(
                          text: l10n.previous,
                          onPressed: () => setState(() => _selectedStep--),
                          backgroundColor: AppColors.surfaceContainerHighest,
                          textColor: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md.w),
                    ],
                    Expanded(
                      child: PrimaryButton(
                        text: _selectedStep < steps.length - 1
                            ? l10n.next
                            : l10n.finished,
                        onPressed: () {
                          if (_selectedStep < steps.length - 1) {
                            setState(() => _selectedStep++);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GuideStep {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;
  const _GuideStep({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
  });
}

class _StepContent extends StatelessWidget {
  final _GuideStep step;
  final int index;
  final int totalSteps;
  const _StepContent({
    super.key,
    required this.step,
    required this.index,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          width: 88.w,
          height: 88.w,
          decoration: BoxDecoration(color: step.iconBg, shape: BoxShape.circle),
          child: Icon(step.icon, color: step.iconColor, size: 44.sp),
        ),
        SizedBox(height: AppSpacing.lg.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: step.iconBg,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            l10n.stepOf(index + 1, totalSteps),
            style: AppTypography.bodySm.copyWith(
              color: step.iconColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md.h),
        Text(step.title, style: AppTypography.h2, textAlign: TextAlign.center),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          step.description,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.textSecondary,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
