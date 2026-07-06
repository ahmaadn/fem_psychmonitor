import 'package:fem_psychmonitor/app/config/app_colors.dart';
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

class MbtiTestPage extends StatelessWidget {
  const MbtiTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final isEnglish = localeProvider.isEnglish;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary, size: 22.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.mbtiTest, style: AppTypography.fraunces(size: 18)),
        centerTitle: true,
      ),
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
            final selectedOption = viewModel.getSelectedMbtiOption(currentIndex);
            final isLast = currentIndex == data.questionnaire.length - 1;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9999.r),
                    child: LinearProgressIndicator(
                      value: (currentIndex + 1) / data.questionnaire.length,
                      backgroundColor: AppColors.outline,
                      color: AppColors.primary,
                      minHeight: 8.h,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.questionXOfY(currentIndex + 1, data.questionnaire.length),
                    style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Text(
                      question.question.get(isEnglish),
                      style: AppTypography.fraunces(size: 16, weight: FontWeight.w500, height: 1.5),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Expanded(
                    child: ListView.builder(
                      itemCount: question.options.length,
                      itemBuilder: (context, i) {
                        final option = question.options[i];
                        final isSelected = selectedOption == option;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: GestureDetector(
                            onTap: () => viewModel.answerMbtiQuestion(currentIndex, option),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.outline,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      option.answer.get(isEnglish),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      if (currentIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => viewModel.previousMbtiQuestion(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.outline),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                            child: Text(l10n.back,
                                style: const TextStyle(color: AppColors.textSecondary)),
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
