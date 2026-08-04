import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PsychTestPage extends StatelessWidget {
  const PsychTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final isEnglish = localeProvider.isEnglish;

    return Scaffold(
      backgroundColor: p.canvas,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: p.textSecondary,
            size: 22.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.mentalHealthAssessment,
          style: AppTypography.bodyStrong.copyWith(
            fontSize: 18.0,
            color: p.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(color: p.canvas),
        child: SafeArea(
          child: Consumer<QuestionnaireViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = viewModel.psychData;
              if (data == null || data.assessment.questions.isEmpty) {
                return Center(child: Text(l10n.failedToLoadQuestionnaire));
              }

              final questions = data.assessment.questions;
              final isComplete = viewModel.isPsychTestComplete();

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        final selectedOption = viewModel.getSelectedPsychOption(
                          index,
                        );

                        return Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: p.surface1,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: p.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: p.primaryFill.withValues(
                                    alpha: 0.16,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: Text(
                                  question.category.get(isEnglish),
                                  style: AppTypography.caption.copyWith(
                                    color: p.primaryText,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                "${index + 1}. ${question.question.get(isEnglish)}",
                                style: AppTypography.bodyStrong.copyWith(
                                  color: p.textPrimary,
                                ),
                              ),
                              SizedBox(height: AppSpacing.md.h),
                              ...question.options.map((option) {
                                final isSelected = selectedOption == option;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
                                  child: GestureDetector(
                                    onTap: () => viewModel.answerPsychQuestion(
                                      index,
                                      option,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md.w,
                                        vertical: AppSpacing.buttonY.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? p.primaryWash
                                            : p.surface2,
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                        border: Border.all(
                                          color: isSelected
                                              ? p.primaryText
                                              : p.divider,
                                          width: isSelected
                                              ? AppBorder.medium
                                              : AppBorder.thin,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSelected
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            color: isSelected
                                                ? p.primaryText
                                                : p.textSecondary,
                                            size: AppSpacing.lg.sp,
                                          ),
                                          SizedBox(width: AppSpacing.sm.w),
                                          Expanded(
                                            child: Text(
                                              option.answer.get(isEnglish),
                                              style: AppTypography.label.copyWith(
                                                color: isSelected
                                                    ? p.primaryText
                                                    : p.textPrimary,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: p.surface1,
                      border: Border.all(color: p.divider),
                    ),
                    child: PrimaryButton(
                      text: l10n.finishAndGoToRecording,
                      isDisabled: !isComplete,
                      onPressed: () {
                        viewModel.calculatePsychResult();
                        context.pushNamed(RouteNames.psychResult);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
