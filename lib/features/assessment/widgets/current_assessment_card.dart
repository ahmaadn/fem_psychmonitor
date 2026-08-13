import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/app/widgets/session_card.dart';
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
        : _ScoreStatus.fromScore(psychScore, p, isEnglish: isEnglish);

    return SessionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.currentAssessment,
            style: AppTypography.subtitle.copyWith(color: p.textPrimary),
          ),
          SizedBox(height: AppSpacing.sm.h),
          if (!hasPsych)
            Text(
              l10n.noAssessmentYet,
              style: AppTypography.body.copyWith(color: p.textSecondary),
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

  /// Semantic bands only — never emotion palette for system score status.
  factory _ScoreStatus.fromScore(
    int score,
    AppPalette p, {
    required bool isEnglish,
  }) {
    if (score >= 80) {
      return _ScoreStatus(
        emoji: '🌿',
        icon: Icons.eco_rounded,
        color: p.successText,
        label: isEnglish ? 'Stable' : 'Stabil',
      );
    }
    if (score >= 60) {
      return _ScoreStatus(
        emoji: '🙂',
        icon: Icons.sentiment_satisfied_alt_rounded,
        color: p.infoText,
        label: isEnglish ? 'Fair' : 'Cukup',
      );
    }
    if (score >= 40) {
      return _ScoreStatus(
        emoji: '🫧',
        icon: Icons.water_drop_outlined,
        color: p.warningText,
        label: isEnglish ? 'Vulnerable' : 'Rentan',
      );
    }
    return _ScoreStatus(
      emoji: '🛟',
      icon: Icons.health_and_safety_rounded,
      color: p.errorText,
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
    final color = status?.color ?? p.primaryText;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm.w + 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    status?.emoji ?? '♡',
                    style: AppTypography.emojiMd,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.xs.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: AppTypography.label.copyWith(
                        color: p.textTertiary,
                      ),
                    ),
                    Text(
                      status?.label ?? '',
                      style: AppTypography.bodyStrong.copyWith(color: color),
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
          SizedBox(height: AppSpacing.xs.h + 2),
          Text(
            scoreText,
            style: AppTypography.subtitle.copyWith(color: p.textPrimary),
          ),
          if (score != null) ...[
            SizedBox(height: AppSpacing.xs.h),
            ClipRRect(
              borderRadius: AppRadius.chip,
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 7.h,
                backgroundColor: p.surface3,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
          if (calculationText != null) ...[
            SizedBox(height: AppSpacing.xs.h),
            Text(
              calculationText!,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.xxs.h),
          Text(
            footnote,
            style: AppTypography.caption.copyWith(color: p.textTertiary),
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
