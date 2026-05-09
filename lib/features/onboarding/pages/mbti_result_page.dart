import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MbtiResultPage extends StatelessWidget {
  const MbtiResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: l10n.mbtiResultTitle, showBackButton: true),
      body: SafeArea(
        child: Consumer<QuestionnaireViewModel>(
          builder: (context, viewModel, child) {
            final mbti = viewModel.finalMbti;
            
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Icon(
                    Icons.psychology_alt,
                    size: 80.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    l10n.yourPersonalityType,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    mbti ?? l10n.unknown,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    l10n.mbtiResultDesc,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    text: l10n.continueToMentalHealth,
                    onPressed: () {
                      context.pushNamed(RouteNames.psychTest);
                    },
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
