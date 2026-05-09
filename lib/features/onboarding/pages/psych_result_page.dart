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

class PsychResultPage extends StatelessWidget {
  const PsychResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final isEnglish = localeProvider.isEnglish;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: l10n.mentalHealthResultTitle, showBackButton: false),
      body: SafeArea(
        child: Consumer<QuestionnaireViewModel>(
          builder: (context, viewModel, child) {
            final score = viewModel.psychScore ?? 0;
            final psychClass = viewModel.psychClass;
            
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.yourScore,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "$score / 100",
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: 24.h),
                        if (psychClass != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              psychClass.className.get(isEnglish),
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            psychClass.description.get(isEnglish),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            l10n.suggestionLabel(psychClass.recommendation.get(isEnglish)),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 48.h),
                  Text(
                    l10n.tryVoiceTestQuestion,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 24.h),
                  PrimaryButton(
                    text: l10n.tryVoiceTest,
                    onPressed: () {
                      context.goNamed(RouteNames.liveRecording);
                    },
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: OutlinedButton(
                      onPressed: () {
                        context.goNamed(RouteNames.home);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        l10n.goToDashboard,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
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
