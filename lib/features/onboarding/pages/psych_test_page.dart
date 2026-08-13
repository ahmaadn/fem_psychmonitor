import 'dart:async';

import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/features/onboarding/models/psych_model.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Mental-health assessment: one question per screen, auto-advances to the
/// next question shortly after the user picks an answer.
class PsychTestPage extends StatefulWidget {
  const PsychTestPage({super.key});

  @override
  State<PsychTestPage> createState() => _PsychTestPageState();
}

class _PsychTestPageState extends State<PsychTestPage> {
  /// Delay after a selection before auto-advancing to the next question.
  /// Long enough for the user to see the highlight, short enough to feel
  /// snappy.
  static const _autoAdvanceDelay = Duration(milliseconds: 280);

  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    // Place the cursor at the first unanswered question so resuming a
    // partially-completed test picks up where the user left off.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<QuestionnaireViewModel>();
      if (vm.psychTotalQuestions > 0) vm.resetPsychCursor();
    });
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  void _onOptionSelected(
    QuestionnaireViewModel vm,
    int index,
    PsychOption option,
  ) {
    vm.answerPsychQuestion(index, option);

    _advanceTimer?.cancel();
    // On the last question, surface a Finish button instead of auto-navigating
    // so the user has an explicit confirmation step before seeing the result.
    if (index >= vm.psychTotalQuestions - 1) return;

    _advanceTimer = Timer(_autoAdvanceDelay, () {
      if (!mounted) return;
      vm.nextPsychQuestion();
    });
  }

  void _goBack(QuestionnaireViewModel vm) {
    _advanceTimer?.cancel();
    if (vm.currentPsychIndex > 0) {
      vm.previousPsychQuestion();
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = context.watch<LocaleProvider>().isEnglish;

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
          onPressed: () => _goBack(context.read<QuestionnaireViewModel>()),
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
            builder: (context, vm, _) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = vm.psychData;
              if (data == null || data.assessment.questions.isEmpty) {
                return Center(child: Text(l10n.failedToLoadQuestionnaire));
              }

              final questions = data.assessment.questions;
              final total = questions.length;
              final index = vm.currentPsychIndex.clamp(0, total - 1);
              final question = questions[index];
              final selectedOption = vm.getSelectedPsychOption(index);
              final isLast = index == total - 1;
              final progress = (index + 1) / total;

              return PopScope(
                canPop: index == 0,
                onPopInvokedWithResult: (didPop, _) {
                  if (didPop) return;
                  _advanceTimer?.cancel();
                  vm.previousPsychQuestion();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageX.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        borderRadius:
                            BorderRadius.circular(AppRadius.pill),
                        backgroundColor: p.surface3,
                        color: p.primaryFill,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${index + 1} / $total',
                        style: AppTypography.caption
                            .copyWith(color: p.textSecondary),
                      ),
                      SizedBox(height: 24.h),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            final offset = Tween<Offset>(
                              begin: const Offset(0.08, 0),
                              end: Offset.zero,
                            ).animate(animation);
                            return SlideTransition(
                              position: offset,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: _PsychQuestionCard(
                            key: ValueKey<int>(index),
                            question: question,
                            selectedOption: selectedOption,
                            isEnglish: isEnglish,
                            onSelect: (option) =>
                                _onOptionSelected(vm, index, option),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SecondaryButton(
                              text: isEnglish ? 'Back' : 'Kembali',
                              textColor: p.primaryText,
                              borderColor: p.primary,
                              onPressed: index == 0
                                  ? () => context.pop()
                                  : vm.previousPsychQuestion,
                            ),
                          ),
                          // No "Next" button: picking an option auto-advances
                          // (see _onOptionSelected). Only the last question
                          // gets an explicit CTA, because it is deliberately
                          // not auto-navigated.
                          if (isLast) ...[
                            SizedBox(width: 12.w),
                            Expanded(
                              child: PrimaryButton(
                                text: l10n.finishAndGoToRecording,
                                isDisabled: selectedOption == null,
                                onPressed: selectedOption != null
                                    ? () {
                                        _advanceTimer?.cancel();
                                        vm.calculatePsychResult();
                                        context.pushNamed(
                                          RouteNames.psychResult,
                                        );
                                      }
                                    : () {},
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PsychQuestionCard extends StatelessWidget {
  const _PsychQuestionCard({
    super.key,
    required this.question,
    required this.selectedOption,
    required this.isEnglish,
    required this.onSelect,
  });

  final PsychQuestion question;
  final PsychOption? selectedOption;
  final bool isEnglish;
  final ValueChanged<PsychOption> onSelect;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: AppSpacing.md.h),
      child: Container(
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
                color: p.primaryFill.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppRadius.sm),
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
              question.question.get(isEnglish),
              style: AppTypography.bodyStrong.copyWith(
                fontSize: 18.sp,
                color: p.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            ...question.options.map((option) {
              final isSelected = selectedOption == option;
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md.w,
                      vertical: AppSpacing.buttonY.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? p.primaryWash : p.surface2,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected ? p.primaryText : p.divider,
                        width:
                            isSelected ? AppBorder.medium : AppBorder.thin,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color:
                              isSelected ? p.primaryText : p.textSecondary,
                          size: AppSpacing.lg.sp,
                        ),
                        SizedBox(width: AppSpacing.sm.w),
                        Expanded(
                          child: Text(
                            option.answer.get(isEnglish),
                            style: AppTypography.label.copyWith(
                              color:
                                  isSelected ? p.primaryText : p.textPrimary,
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
      ),
    );
  }
}