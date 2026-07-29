import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/session_card.dart';
import 'package:fem_psychmonitor/features/onboarding/models/ocean_model.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OceanResultPage extends StatelessWidget {
  const OceanResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final vm = context.watch<QuestionnaireViewModel>();
    final isEn = context.watch<LocaleProvider>().isEnglish;
    final scores = vm.oceanScores;

    return Scaffold(
      backgroundColor: p.canvas,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEn ? 'OCEAN Result' : 'Hasil OCEAN',
          style: AppTypography.subtitle.copyWith(color: p.textPrimary),
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: p.canvasGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.pageX.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEn ? 'Your Big Five profile' : 'Profil Big Five Anda',
                  style: AppTypography.display.copyWith(color: p.textPrimary),
                ),
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  isEn
                      ? 'All items completed. Continue to mental health assessment.'
                      : 'Semua item selesai. Lanjut ke asesmen kesehatan mental.',
                  style: AppTypography.body.copyWith(color: p.textSecondary),
                ),
                SizedBox(height: AppSpacing.xl.h),
                if (scores != null)
                  Expanded(
                    child: ListView(
                      children: OceanTrait.values.map((t) {
                        final s = scores.scoreOf(t);
                        final level = scores.levelOf(t);
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
                          child: SessionCard(
                            elevated: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      t.label(isEn),
                                      style: AppTypography.bodyStrong
                                          .copyWith(color: p.textPrimary),
                                    ),
                                    Text(
                                      isEn ? level.labelEn : level.labelId,
                                      style: AppTypography.label
                                          .copyWith(color: p.primaryText),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppSpacing.xs.h),
                                ClipRRect(
                                  borderRadius: AppRadius.chip,
                                  child: LinearProgressIndicator(
                                    value: ((s - 1) / 4).clamp(0.0, 1.0),
                                    minHeight: 8.h,
                                    backgroundColor: p.surface3,
                                    valueColor: AlwaysStoppedAnimation(
                                      p.primaryFill,
                                    ),
                                  ),
                                ),
                                SizedBox(height: AppSpacing.xxs.h),
                                Text(
                                  s.toStringAsFixed(2),
                                  style: AppTypography.caption
                                      .copyWith(color: p.textTertiary),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                else
                  const Spacer(),
                PrimaryButton(
                  text: isEn
                      ? 'Continue to mental health'
                      : 'Lanjut asesmen mental',
                  onPressed: () => context.pushNamed(RouteNames.psychTest),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
