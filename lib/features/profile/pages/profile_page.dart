import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/mental_health_score.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/profile_viewmodel.dart';
import 'package:fem_psychmonitor/features/onboarding/models/ocean_model.dart';
import 'package:fem_psychmonitor/features/profile/pages/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Identity-focused profile tab.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final isEn = context.watch<LocaleProvider>().isEnglish;
    final profileVm = context.watch<ProfileViewModel>();
    final auth = context.watch<AuthViewModel>();
    final user = profileVm.user ?? auth.currentUser;
    final ocean = user?.oceanScores;
    final score = user?.psychScore;
    final classKey =
        user?.psychClass ??
        (score != null ? psychClassKeyForScore(score) : null);
    final initial = (user?.fullName.isNotEmpty == true)
        ? user!.fullName[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: p.canvas,
      body: CustomScrollView(
        slivers: [
          // ── Hero identity panel ─────────────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHero(
              initial: initial,
              name: user?.fullName ?? '—',
              subtitle: user?.isGuest == true
                  ? (isEn ? 'Guest account' : 'Akun tamu')
                  : (user?.email ?? ''),
              score: score,
              classKey: classKey,
              isEn: isEn,
              onEditTap: () async {
                final vm = context.read<ProfileViewModel>();
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
                if (mounted) {
                  vm.loadProfile();
                }
              },
            ),
          ),

          // ── Body ────────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageX.w,
              AppSpacing.md.h,
              AppSpacing.pageX.w,
              120.h,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // OCEAN traits
                if (ocean != null) ...[
                  _SectionHeader(
                    label: 'Big Five (OCEAN)',
                    icon: Icons.psychology_rounded,
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  _OceanGrid(ocean: ocean, isEn: isEn),
                  SizedBox(height: AppSpacing.lg.h),
                ],

                // Action links
                _SectionHeader(
                  label: isEn ? 'Account' : 'Akun',
                  icon: Icons.manage_accounts_rounded,
                ),
                SizedBox(height: AppSpacing.sm.h),
                _ActionCard(
                  items: [
                    _ActionItem(
                      icon: Icons.edit_outlined,
                      label: l10n.editProfile,
                      chip: IconChipFamily.primary,
                      onTap: () async {
                        final vm = context.read<ProfileViewModel>();
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        );
                        if (mounted) {
                          vm.loadProfile();
                        }
                      },
                    ),
                    if (user?.isGuest != true)
                      _ActionItem(
                        icon: Icons.lock_outline,
                        label: l10n.changePassword,
                        chip: IconChipFamily.primary,
                        onTap: () =>
                            context.pushNamed(RouteNames.changePassword),
                      ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Hero ─────────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.initial,
    required this.name,
    required this.subtitle,
    required this.score,
    required this.classKey,
    required this.isEn,
    required this.onEditTap,
  });

  final String initial;
  final String name;
  final String subtitle;
  final int? score;
  final String? classKey;
  final bool isEn;
  final VoidCallback onEditTap;

  Color _scoreColor(int s, AppPalette p) {
    if (s <= 25) return p.error;
    if (s <= 50) return p.warning;
    if (s <= 75) return p.secondaryText;
    return p.secondaryText;
  }

  String _classLabel(String? key, bool isEn) {
    return switch (key) {
      'butuh_perhatian' => isEn ? 'Needs attention' : 'Butuh Perhatian',
      'rentan' => isEn ? 'Vulnerable' : 'Rentan',
      'cukup_sehat' => isEn ? 'Fairly healthy' : 'Cukup Sehat',
      'sehat' => isEn ? 'Healthy' : 'Sehat',
      _ => key ?? '—',
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final sc = score;
    final scoreColor = sc != null ? _scoreColor(sc, p) : p.primaryText;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + AppSpacing.md.h,
        left: AppSpacing.pageX.w,
        right: AppSpacing.pageX.w,
        bottom: AppSpacing.xl.h,
      ),
      decoration: BoxDecoration(color: p.surface1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 68.w,
                height: 68.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.primarySoft,
                  border: Border.all(color: p.primaryText, width: AppBorder.thin),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: AppTypography.title.copyWith(
                    color: p.primaryText,
                    height: 1,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md.w),

              // Name + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.h),
                    Text(
                      name,
                      style: AppTypography.title.copyWith(
                        color: p.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs.h),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Edit button
              GestureDetector(
                onTap: onEditTap,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.xs.w),
                  decoration: BoxDecoration(
                    color: p.surface1.withValues(alpha: 0.8),
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      color: p.primaryFill.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: p.primaryText,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),

          // Score bar (if exists)
          if (sc != null) ...[
            SizedBox(height: AppSpacing.lg.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$sc',
                            style: AppTypography.display.copyWith(
                              color: p.textPrimary,
                              height: 1,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '/ 100',
                            style: AppTypography.caption.copyWith(
                              color: p.textTertiary,
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: scoreColor.withValues(alpha: 0.18),
                              borderRadius: AppRadius.chip,
                            ),
                            child: Text(
                              _classLabel(classKey, isEn),
                              style: AppTypography.caption.copyWith(
                                color: scoreColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      ClipRRect(
                        borderRadius: AppRadius.chip,
                        child: LinearProgressIndicator(
                          value: sc / 100,
                          minHeight: 6.h,
                          backgroundColor: p.primaryFill.withValues(
                            alpha: 0.15,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── OCEAN Grid ───────────────────────────────────────────────────────────────

class _OceanGrid extends StatelessWidget {
  const _OceanGrid({required this.ocean, required this.isEn});
  final OceanScores ocean;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final traits = OceanTrait.values;
    final traitFills = [
      p.secondarySoft,
      p.primarySoft,
      p.info.withValues(alpha: 0.15),
      p.emotionBase(EmotionLabelType.fearful).withValues(alpha: 0.15),
      p.surface2,
    ];
    final traitBorders = [
      p.secondaryFill,
      p.primaryFill,
      p.info,
      p.emotionBase(EmotionLabelType.fearful),
      p.textTertiary,
    ];

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: List.generate(traits.length, (i) {
        final t = traits[i];
        final level = ocean.levelOf(t);
        final s = ocean.scoreOf(t);
        final bg = traitFills[i];
        final border = traitBorders[i].withValues(alpha: 0.3);

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.xs.h,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.card,
            border: Border.all(color: border, width: AppBorder.thin),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.code,
                style: AppTypography.label.copyWith(color: traitBorders[i]),
              ),
              SizedBox(height: 2.h),
              Text(
                s.toStringAsFixed(1),
                style: AppTypography.bodyStrong.copyWith(color: p.textPrimary),
              ),
              Text(
                isEn ? level.labelEn : level.labelId,
                style: AppTypography.label.copyWith(color: p.textSecondary),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            color: p.surface2,
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Icon(icon, color: p.textSecondary, size: 12.sp),
        ),
        SizedBox(width: AppSpacing.xs.w),
        Text(
          label,
          style: AppTypography.bodyStrong.copyWith(color: p.textPrimary),
        ),
      ],
    );
  }
}

// ── Action Card ──────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.items});
  final List<_ActionItem> items;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface1,
        borderRadius: AppRadius.card,
        border: Border.all(color: p.divider, width: AppBorder.thin),
        boxShadow: [
          BoxShadow(
            color: p.shadowRaised,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: p.iconChipFill(entry.value.chip),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    entry.value.icon,
                    color: p.iconChipIcon(entry.value.chip),
                    size: 16.sp,
                  ),
                ),
                title: Text(
                  entry.value.label,
                  style: AppTypography.body.copyWith(color: p.textPrimary),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: p.textTertiary,
                  size: 18.sp,
                ),
                onTap: entry.value.onTap,
              ),
              if (!isLast) Divider(color: p.divider, height: 1, indent: 56.w),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  /// Icon-chip color family, assigned by row category (DESIGN.md §4).
  final IconChipFamily chip;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.chip,
    this.onTap,
  });
}
