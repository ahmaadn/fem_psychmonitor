import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/voiceprint_orb.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary, size: 22.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.mbtiResultTitle, style: AppTypography.fraunces(size: 18)),
        centerTitle: true,
      ),
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
                  const VoiceprintOrb(mode: VoiceprintMode.idle, size: 180),
                  SizedBox(height: 28.h),
                  Text(
                    l10n.yourPersonalityType,
                    style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    mbti ?? l10n.unknown,
                    style: AppTypography.fraunces(size: 40),
                  ),
                  SizedBox(height: 24.h),
                  if (viewModel.hasDimensionCounts) ...[
                    _buildDimensionBars(context, l10n, viewModel),
                    SizedBox(height: 24.h),
                  ],
                  SizedBox(
                    width: 280.w,
                    child: Text(
                      l10n.mbtiResultDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.sp, height: 1.55, color: AppColors.textSecondary),
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    text: l10n.continueToMentalHealth,
                    onPressed: () => context.pushNamed(RouteNames.psychTest),
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

  Widget _buildDimensionBars(BuildContext context, AppLocalizations l10n, QuestionnaireViewModel viewModel) {
    final pairs = viewModel.mbtiDimensionPercentages;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.mbtiDimensionScores, style: AppTypography.fraunces(size: 15)),
          SizedBox(height: 14.h),
          ...pairs.map((d) => _buildDimensionBar(context, d)),
        ],
      ),
    );
  }

  Widget _buildDimensionBar(BuildContext context, ({String left, int leftPct, String right, int rightPct}) d) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${d.left} ${d.leftPct}%',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.primary)),
              Text('${d.rightPct}% ${d.right}',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999.r),
            child: SizedBox(
              height: 8.h,
              child: LinearProgressIndicator(
                value: (d.leftPct / 100).clamp(0.0, 1.0),
                minHeight: 8.h,
                backgroundColor: AppColors.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
