import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MbtiTestPage extends StatelessWidget {
  const MbtiTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final isEnglish = localeProvider.isEnglish;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: l10n.mbtiTest, showBackButton: true),
      body: SafeArea(
        child: Consumer<QuestionnaireViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = viewModel.mbtiData;
            if (data == null || data.questionnaire.isEmpty) {
              return Center(child: Text(l10n.failedToLoadQuestionnaire));
            }

            final currentIndex = viewModel.currentMbtiIndex;
            final question = data.questionnaire[currentIndex];
            final selectedOption = viewModel.getSelectedMbtiOption(
              currentIndex,
            );
            final isLast = currentIndex == data.questionnaire.length - 1;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (currentIndex + 1) / data.questionnaire.length,
                    backgroundColor: AppColors.outline,
                    color: AppColors.primary,
                    minHeight: 8.h,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.questionXOfY(currentIndex + 1, data.questionnaire.length),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Text(
                      question.question.get(isEnglish),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  ...question.options.map((option) {
                    final isSelected = selectedOption == option;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: InkWell(
                        onTap: () {
                          viewModel.answerMbtiQuestion(currentIndex, option);
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.outline,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  option.answer.get(isEnglish),
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const Spacer(),
                  Row(
                    children: [
                      if (currentIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              viewModel.previousMbtiQuestion();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.outline),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                            ),
                            child: Text(
                              l10n.back,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      if (currentIndex > 0) SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: PrimaryButton(
                          text: isLast ? l10n.finishAndContinue : l10n.nextQuestion,
                          isDisabled: selectedOption == null,
                          onPressed: () {
                            if (isLast) {
                              viewModel.calculateMbtiResult();
                              context.pushNamed(RouteNames.mbtiResult);
                            } else {
                              viewModel.nextMbtiQuestion();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
