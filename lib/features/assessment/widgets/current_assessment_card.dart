import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/profile_viewmodel.dart';
import 'package:fem_psychmonitor/features/onboarding/models/psych_model.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CurrentAssessmentCard extends StatelessWidget {
  const CurrentAssessmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final profileVm = context.watch<ProfileViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final questionnaireVm = context.read<QuestionnaireViewModel>();
    final isEnglish = context.watch<LocaleProvider>().isEnglish;
    final user = profileVm.user ?? authVm.currentUser;

    final psychScore = user?.psychScore;
    final psychClass = resolveLocalizedPsychClass(
      user?.psychClass,
      questionnaireVm.psychData,
      isEnglish,
    );
    final hasPsych = psychScore != null || psychClass != null;
    final psychStatus = psychScore == null
        ? null
        : _ScoreStatus.fromScore(psychScore, isEnglish: isEnglish);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: p.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.currentAssessment, style: AppTypography.bodyStrong.copyWith(fontSize: 16.0)),
          SizedBox(height: 12.h),
          if (!hasPsych)
            Text(
              l10n.noAssessmentYet,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.5,
                color: p.inkMuted,
              ),
            )
          else
            _MentalHealthTile(
              status: psychStatus,
              label: l10n.mentalHealthScore,
              scoreText: [
                psychScore != null ? '$psychScore/100' : null,
                psychClass,
              ].whereType<String>().join(' · '),
              calculationText: psychScore == null
                  ? null
                  : (isEnglish
                        ? 'Calculation: $psychScore / 100 = $psychScore%'
                        : 'Perhitungan: $psychScore / 100 = $psychScore%'),
              footnote: isEnglish
                  ? 'Updated from assessment results, model confidence, and emotion corrections.'
                  : 'Diperbarui dari hasil asesmen, confidence model, dan koreksi emosi.',
            ),
        ],
      ),
    );
  }
}

class _ScoreStatus {
  const _ScoreStatus({
    required this.emoji,
    required this.icon,
    required this.color,
    required this.label,
  });

  final String emoji;
  final IconData icon;
  final Color color;
  final String label;

  factory _ScoreStatus.fromScore(int score, {required bool isEnglish}) {
    if (score >= 80) {
      return _ScoreStatus(
        emoji: '🌿',
        icon: Icons.eco_rounded,
        color: AppColors.emotionHappiness,
        label: isEnglish ? 'Stable' : 'Stabil',
      );
    }
    if (score >= 60) {
      return _ScoreStatus(
        emoji: '🙂',
        icon: Icons.sentiment_satisfied_alt_rounded,
        color: AppColors.primary,
        label: isEnglish ? 'Fair' : 'Cukup',
      );
    }
    if (score >= 40) {
      return _ScoreStatus(
        emoji: '🫧',
        icon: Icons.water_drop_outlined,
        color: AppColors.secondary,
        label: isEnglish ? 'Vulnerable' : 'Rentan',
      );
    }
    return _ScoreStatus(
      emoji: '🛟',
      icon: Icons.health_and_safety_rounded,
      color: AppColors.warning,
      label: isEnglish ? 'Needs attention' : 'Butuh perhatian',
    );
  }
}

class _MentalHealthTile extends StatelessWidget {
  const _MentalHealthTile({
    required this.status,
    required this.label,
    required this.scoreText,
    required this.calculationText,
    required this.footnote,
  });

  final _ScoreStatus? status;
  final String label;
  final String scoreText;
  final String? calculationText;
  final String footnote;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final score = _scoreFromText(scoreText);
    final color = status?.color ?? p.primary;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    status?.emoji ?? '♡',
                    style: TextStyle(fontSize: 18.sp),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: p.inkMuted,
                      ),
                    ),
                    Text(
                      status?.label ?? '',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                status?.icon ?? Icons.favorite_rounded,
                color: color,
                size: 18.sp,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            scoreText,
            style: AppTypography.tagline,
          ),
          if (score != null) ...[
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: AppRadius.chip,
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 7.h,
                backgroundColor: p.strawberry,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
          if (calculationText != null) ...[
            SizedBox(height: 8.h),
            Text(
              calculationText!,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
          SizedBox(height: 4.h),
          Text(
            footnote,
            style: TextStyle(
              fontSize: 10.sp,
              height: 1.35,
              color: p.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  int? _scoreFromText(String text) {
    final match = RegExp(r'^(\d{1,3})/100').firstMatch(text);
    final value = match == null ? null : int.tryParse(match.group(1)!);
    if (value == null) return null;
    return value.clamp(0, 100);
  }
}
