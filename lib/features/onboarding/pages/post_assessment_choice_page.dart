import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/features/onboarding/models/ocean_model.dart';
import 'package:fem_psychmonitor/features/onboarding/utils/onboarding_result_persistence.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Shown after assessment when user started from onboarding "Start app"
/// without being signed in yet.
class PostAssessmentChoicePage extends StatefulWidget {
  const PostAssessmentChoicePage({super.key});

  @override
  State<PostAssessmentChoicePage> createState() =>
      _PostAssessmentChoicePageState();
}

class _PostAssessmentChoicePageState extends State<PostAssessmentChoicePage> {
  bool _busy = false;

  Future<void> _asGuest() async {
    setState(() => _busy = true);
    final auth = context.read<AuthViewModel>();
    final q = context.read<QuestionnaireViewModel>();
    final ok = await auth.continueAsGuest();
    if (!mounted) return;
    if (ok) {
      await persistOnboardingResults(authVm: auth, questionnaireVm: q);
    }
    if (!mounted) return;
    setState(() => _busy = false);
    context.goNamed(RouteNames.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isEn = context.watch<LocaleProvider>().isEnglish;
    final vm = context.watch<QuestionnaireViewModel>();

    return Scaffold(
      backgroundColor: p.canvas,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: p.brandFadeGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.pageX.w,
                    AppSpacing.xl.h,
                    AppSpacing.pageX.w,
                    AppSpacing.lg.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DoneBadge(isEn: isEn, p: p),
                      SizedBox(height: AppSpacing.lg.h),
                      Text(
                        isEn ? 'Almost there' : 'Hampir selesai',
                        style: AppTypography.display.copyWith(
                          color: p.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        isEn
                            ? 'Your assessment is ready. Save it as a guest, or '
                                  'create an account so it stays with you.'
                            : 'Hasil asesmen Anda sudah siap. Simpan sebagai '
                                  'tamu, atau buat akun agar tetap tersimpan.',
                        style: AppTypography.body.copyWith(
                          color: p.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.xl.h),
                      _ResultSummaryCard(
                        isEn: isEn,
                        p: p,
                        score: vm.psychScore,
                        className: vm.psychClass?.className.get(isEn),
                        scores: vm.oceanScores,
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      _ChoiceComparison(isEn: isEn, p: p),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageX.w,
                  AppSpacing.md.h,
                  AppSpacing.pageX.w,
                  AppSpacing.md.h,
                ),
                decoration: BoxDecoration(
                  color: p.canvas,
                  border: Border(top: p.hairlineSide),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PrimaryButton(
                      text: isEn ? 'Create account' : 'Buat akun',
                      prefixIcon: Icons.person_add_alt_1_outlined,
                      isDisabled: _busy,
                      onPressed: () => context.pushNamed(RouteNames.register),
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    SecondaryButton(
                      text: _busy
                          ? (isEn ? 'Saving…' : 'Menyimpan…')
                          : (isEn
                                ? 'Continue as guest'
                                : 'Lanjut sebagai tamu'),
                      icon: _busy ? null : Icons.arrow_forward_rounded,
                      textColor: p.textSecondary,
                      borderColor: p.divider,
                      isDisabled: _busy,
                      onPressed: _asGuest,
                    ),
                    SizedBox(height: AppSpacing.xs.h),
                    Text(
                      isEn
                          ? 'Guest data stays on this device only.'
                          : 'Data tamu hanya tersimpan di perangkat ini.',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: p.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── "Assessment complete" pill ────────────────────────────────────────
class _DoneBadge extends StatelessWidget {
  const _DoneBadge({required this.isEn, required this.p});

  final bool isEn;
  final AppPalette p;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.xs.h,
        ),
        decoration: BoxDecoration(
          color: p.success.withValues(alpha: p.isDark ? 0.18 : 0.13),
          borderRadius: AppRadius.chip,
          border: Border.all(
            color: p.success.withValues(alpha: 0.30),
            width: AppBorder.thin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 16.sp, color: p.successText),
            SizedBox(width: AppSpacing.xxs.w + 2.w),
            Text(
              isEn ? 'ASSESSMENT COMPLETE' : 'ASESMEN SELESAI',
              style: AppTypography.label.copyWith(color: p.successText),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary of what is about to be saved ──────────────────────────────
class _ResultSummaryCard extends StatelessWidget {
  const _ResultSummaryCard({
    required this.isEn,
    required this.p,
    required this.score,
    required this.className,
    required this.scores,
  });

  final bool isEn;
  final AppPalette p;
  final int? score;
  final String? className;
  final OceanScores? scores;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: p.card(radius: AppRadius.xl, elevated: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 18.sp,
                color: p.primaryText,
              ),
              SizedBox(width: AppSpacing.xs.w),
              Expanded(
                child: Text(
                  isEn ? 'READY TO SAVE' : 'SIAP DISIMPAN',
                  style: AppTypography.label.copyWith(color: p.textTertiary),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          if (score != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$score',
                      style: AppTypography.metric.copyWith(
                        color: p.textPrimary,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '/100',
                      style: AppTypography.caption.copyWith(
                        color: p.textTertiary,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'Mental health score' : 'Skor kesehatan mental',
                        style: AppTypography.caption.copyWith(
                          color: p.textTertiary,
                        ),
                      ),
                      if (className != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          className!,
                          style: AppTypography.bodyStrong.copyWith(
                            color: p.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),
            Divider(height: 1.h, color: p.divider),
            SizedBox(height: AppSpacing.md.h),
          ],
          Text(
            isEn ? 'Big Five profile' : 'Profil Big Five',
            style: AppTypography.caption.copyWith(color: p.textTertiary),
          ),
          SizedBox(height: AppSpacing.sm.h),
          if (scores != null)
            Row(
              children: OceanTrait.values.map((t) {
                final value = ((scores!.scoreOf(t) - 1) / 4).clamp(0.0, 1.0);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: AppSpacing.xs.w),
                    child: _TraitBar(code: t.code, value: value, p: p),
                  ),
                );
              }).toList(),
            )
          else
            Text(
              isEn
                  ? 'Personality profile saved with your account.'
                  : 'Profil kepribadian ikut tersimpan bersama akun Anda.',
              style: AppTypography.body.copyWith(color: p.textSecondary),
            ),
        ],
      ),
    );
  }
}

class _TraitBar extends StatelessWidget {
  const _TraitBar({required this.code, required this.value, required this.p});

  final String code;
  final double value;
  final AppPalette p;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 56.h,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: value.clamp(0.08, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: p.primaryFill,
                  borderRadius: BorderRadius.circular(AppRadius.xs.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.xxs.h),
        Text(code, style: AppTypography.micro.copyWith(color: p.textTertiary)),
      ],
    );
  }
}

// ── Guest vs account benefits ─────────────────────────────────────────
class _ChoiceComparison extends StatelessWidget {
  const _ChoiceComparison({required this.isEn, required this.p});

  final bool isEn;
  final AppPalette p;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BenefitRow(
          p: p,
          family: IconChipFamily.primary,
          icon: Icons.cloud_done_outlined,
          title: isEn ? 'Backed up' : 'Tersimpan aman',
          subtitle: isEn
              ? 'An account keeps your history if you change devices.'
              : 'Akun menjaga riwayat Anda saat berganti perangkat.',
        ),
        SizedBox(height: AppSpacing.sm.h),
        _BenefitRow(
          p: p,
          family: IconChipFamily.secondary,
          icon: Icons.timeline_rounded,
          title: isEn ? 'Long-term trends' : 'Tren jangka panjang',
          subtitle: isEn
              ? 'Track how your mood shifts week over week.'
              : 'Pantau perubahan suasana hati dari minggu ke minggu.',
        ),
        SizedBox(height: AppSpacing.sm.h),
        _BenefitRow(
          p: p,
          family: IconChipFamily.info,
          icon: Icons.phone_iphone_rounded,
          title: isEn ? 'Guest mode' : 'Mode tamu',
          subtitle: isEn
              ? 'Start now without an email — upgrade any time later.'
              : 'Mulai tanpa email — bisa dibuatkan akun kapan saja.',
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.p,
    required this.family,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final AppPalette p;
  final IconChipFamily family;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: p.iconChipFill(family),
            borderRadius: BorderRadius.circular(AppRadius.md.r),
          ),
          child: Icon(icon, size: 20.sp, color: p.iconChipIcon(family)),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyStrong.copyWith(color: p.textPrimary),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(color: p.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
