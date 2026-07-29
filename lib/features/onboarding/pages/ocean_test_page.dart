import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OceanTestPage extends StatelessWidget {
  const OceanTestPage({super.key});

  static const _labelsId = [
    'Sangat Tidak Sesuai',
    'Tidak Sesuai',
    'Netral',
    'Sesuai',
    'Sangat Sesuai',
  ];
  static const _labelsEn = [
    'Strongly Disagree',
    'Disagree',
    'Neutral',
    'Agree',
    'Strongly Agree',
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final vm = context.watch<QuestionnaireViewModel>();
    final isEn = context.watch<LocaleProvider>().isEnglish;
    final labels = isEn ? _labelsEn : _labelsId;

    if (vm.isLoading) {
      return Scaffold(
        backgroundColor: p.canvas,
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: p.canvasGradient),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (vm.oceanQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: p.canvas,
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: p.canvasGradient),
          child: Center(
            child: Text(
              isEn ? 'No questions loaded' : 'Pertanyaan belum dimuat',
              style: AppTypography.body.copyWith(color: p.textSecondary),
            ),
          ),
        ),
      );
    }

    final q = vm.oceanQuestions[vm.currentOceanIndex];
    final selected = vm.getOceanAnswer(q.id);
    final progress = (vm.currentOceanIndex + 1) / vm.oceanQuestions.length;

    return Scaffold(
      backgroundColor: p.canvas,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEn ? 'Big Five (OCEAN)' : 'Big Five (OCEAN)',
          style: AppTypography.subtitle.copyWith(color: p.textPrimary),
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: p.canvasGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageX.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  backgroundColor: p.primaryWash,
                  color: p.primaryText,
                ),
                SizedBox(height: 8.h),
                Text(
                  '${vm.currentOceanIndex + 1} / ${vm.oceanQuestions.length}',
                  style: AppTypography.caption.copyWith(color: p.textSecondary),
                ),
                SizedBox(height: 24.h),
                Text(
                  q.statement.get(isEn),
                  style: AppTypography.subtitle.copyWith(
                    fontSize: 22.sp,
                    color: p.textPrimary,
                  ),
                ),
                SizedBox(height: 28.h),
                Expanded(
                  child: ListView.separated(
                    itemCount: 5,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, i) {
                      final value = i + 1;
                      final isSel = selected == value;
                      return InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        onTap: () => vm.answerOcean(q.id, value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSel ? p.primary : p.surface1,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: isSel ? p.primaryPressed : p.divider,
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            labels[i],
                            style: AppTypography.body.copyWith(
                              color: isSel ? p.onPrimary : p.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    if (vm.currentOceanIndex > 0)
                      Expanded(
                        child: SecondaryButton(
                          text: isEn ? 'Back' : 'Kembali',
                          onPressed: vm.previousOceanQuestion,
                        ),
                      ),
                    if (vm.currentOceanIndex > 0) SizedBox(width: 12.w),
                    Expanded(
                      child: PrimaryButton(
                        text: vm.currentOceanIndex ==
                                vm.oceanQuestions.length - 1
                            ? (isEn ? 'Finish' : 'Selesai')
                            : (isEn ? 'Next' : 'Lanjut'),
                        isDisabled: selected == null,
                        onPressed: () {
                          if (vm.currentOceanIndex <
                              vm.oceanQuestions.length - 1) {
                            vm.nextOceanQuestion();
                          } else {
                            vm.calculateOceanResult();
                            context.pushNamed(RouteNames.oceanResult);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
