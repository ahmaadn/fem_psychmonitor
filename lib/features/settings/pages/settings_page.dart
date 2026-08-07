import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/app/providers/privacy_provider.dart';
import 'package:fem_psychmonitor/app/providers/theme_provider.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/mental_health_score.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_emoji.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/profile_viewmodel.dart';
import 'package:fem_psychmonitor/features/onboarding/models/ocean_model.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:fem_psychmonitor/features/profile/widgets/sheets/app_guide_sheet.dart';
import 'package:fem_psychmonitor/features/profile/widgets/sheets/terms_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
    final auth = context.watch<AuthViewModel>();
    final profileVm = context.watch<ProfileViewModel>();
    final locale = context.watch<LocaleProvider>();
    final theme = context.watch<ThemeProvider>();
    final isEn = locale.isEnglish;
    final isGuest = auth.isGuest;
    final user = profileVm.user ?? auth.currentUser;
    final score = user?.psychScore;
    final ocean = user?.oceanScores;
    final initial = (user?.fullName.isNotEmpty == true)
        ? user!.fullName[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: p.canvas,
      body: CustomScrollView(
        slivers: [
          // ── Identity header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SettingsIdentityHeader(
              initial: initial,
              name: user?.fullName ?? '—',
              subtitle: user?.isGuest == true
                  ? (isEn ? 'Guest account' : 'Akun tamu')
                  : (user?.email ?? ''),
              score: score,
              isEn: isEn,
              ocean: ocean,
              onEditTap: () => context.pushNamed(RouteNames.editProfile),
            ),
          ),

          // ── Settings body ────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageX.w,
              AppSpacing.md.h,
              AppSpacing.pageX.w,
              80.h,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Preferences
                _SettingsSection(
                  title: isEn ? 'Preferences' : 'Preferensi',
                  icon: Icons.tune_rounded,
                  children: [
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      label: isEn ? 'Language' : 'Bahasa',
                      chip: IconChipFamily.info,
                      trailing: _ValueBadge(text: isEn ? 'EN' : 'ID'),
                      onTap: () async {
                        if (isEn) {
                          await locale.switchToIndonesian();
                        } else {
                          await locale.switchToEnglish();
                        }
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      label: isEn ? 'Theme' : 'Tema',
                      chip: IconChipFamily.secondary,
                      trailing: _ValueBadge(
                        text: theme.mode == ThemeMode.dark
                            ? (isEn ? 'Dark' : 'Gelap')
                            : theme.mode == ThemeMode.system
                            ? 'System'
                            : (isEn ? 'Light' : 'Terang'),
                      ),
                      onTap: () async {
                        final next = switch (theme.mode) {
                          ThemeMode.light => ThemeMode.dark,
                          ThemeMode.dark => ThemeMode.system,
                          ThemeMode.system => ThemeMode.light,
                        };
                        await theme.setMode(next);
                      },
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md.h),

                // Account
                _SettingsSection(
                  title: isEn ? 'Account' : 'Akun',
                  icon: Icons.manage_accounts_rounded,
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      label: isEn ? 'Edit profile' : 'Edit profil',
                      chip: IconChipFamily.primary,
                      onTap: () => context.pushNamed(RouteNames.editProfile),
                    ),
                    if (!isGuest)
                      _SettingsTile(
                        icon: Icons.lock_rounded,
                        label: isEn ? 'Change password' : 'Ganti password',
                        chip: IconChipFamily.primary,
                        onTap: () =>
                            context.pushNamed(RouteNames.changePassword),
                      ),
                    _SettingsTile(
                      icon: Icons.replay_rounded,
                      label: isEn ? 'Retake assessment' : 'Asesmen ulang',
                      chip: IconChipFamily.warning,
                      onTap: () {
                        context
                            .read<QuestionnaireViewModel>()
                            .resetAssessmentProgress();
                        context.pushNamed(RouteNames.oceanTest);
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.cleaning_services_rounded,
                      label: isEn ? 'Reset data' : 'Reset data',
                      chip: IconChipFamily.warning,
                      onTap: () async {
                        final ok = await _confirm(
                          context,
                          isEn
                              ? 'Reset all recordings and assessment data? Account stays.'
                              : 'Hapus semua rekaman dan data asesmen? Akun tetap ada.',
                        );
                        if (ok != true || !context.mounted) return;
                        await auth.resetData();
                        if (!context.mounted) return;
                        context.goNamed(RouteNames.oceanTest);
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.delete_forever_rounded,
                      label: isEn ? 'Delete account' : 'Hapus akun',
                      chip: IconChipFamily.error,
                      onTap: () async {
                        final ok = await _confirm(
                          context,
                          isEn
                              ? 'Delete account and all local data?'
                              : 'Hapus akun dan semua data lokal?',
                        );
                        if (ok != true || !context.mounted) return;
                        await auth.deleteAccount();
                        if (!context.mounted) return;
                        context.goNamed(RouteNames.onboarding);
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      label: isEn ? 'Log out' : 'Keluar',
                      chip: IconChipFamily.error,
                      onTap: () async {
                        await auth.logout();
                        if (!context.mounted) return;
                        context.goNamed(RouteNames.onboarding);
                      },
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md.h),

                // Privacy & help
                _SettingsSection(
                  title: isEn ? 'Privacy & help' : 'Privasi & bantuan',
                  icon: Icons.shield_outlined,
                  children: [
                    Consumer<PrivacyProvider>(
                      builder: (context, privacy, _) {
                        return Column(
                          children: [
                            _PrivacySwitch(
                              icon: Icons.mic_none_rounded,
                              label: isEn
                                  ? 'Keep temp audio after analysis'
                                  : 'Simpan audio sementara setelah analisis',
                              chip: IconChipFamily.warning,
                              value: privacy.storeTempAudio,
                              onChanged: privacy.setStoreTempAudio,
                            ),
                            Divider(
                              color: context.palette.divider,
                              height: 1,
                              indent: 56.w,
                            ),
                            _PrivacySwitch(
                              icon: Icons.bar_chart_rounded,
                              label: isEn
                                  ? 'Anonymous analytics (stub)'
                                  : 'Analitik anonim (stub)',
                              chip: IconChipFamily.secondary,
                              value: privacy.analytics,
                              onChanged: privacy.setAnalytics,
                            ),
                          ],
                        );
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.menu_book_rounded,
                      label: isEn ? 'How to use' : 'Cara pakai',
                      chip: IconChipFamily.info,
                      onTap: () => AppGuideSheet.show(context),
                    ),
                    _SettingsTile(
                      icon: Icons.gavel_rounded,
                      label: isEn ? 'Licence' : 'Lisensi',
                      chip: IconChipFamily.info,
                      onTap: () => TermsSheet.show(context),
                    ),
                    _SettingsTile(
                      icon: Icons.support_agent_rounded,
                      label: isEn ? 'Need help' : 'Butuh bantuan',
                      chip: IconChipFamily.info,
                      onTap: () async {
                        final uri = Uri.parse('tel:119');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
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

  Future<bool?> _confirm(BuildContext context, String message) {
    final p = context.palette;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface1,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        content: Text(
          message,
          style: AppTypography.body.copyWith(color: p.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTypography.body.copyWith(color: p.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'OK',
              style: AppTypography.bodyStrong.copyWith(color: p.warning),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Identity Header ──────────────────────────────────────────────────────────

class _SettingsIdentityHeader extends StatelessWidget {
  const _SettingsIdentityHeader({
    required this.initial,
    required this.name,
    required this.subtitle,
    required this.score,
    required this.isEn,
    required this.ocean,
    required this.onEditTap,
  });

  final String initial;
  final String name;
  final String subtitle;
  final int? score;
  final bool isEn;
  final OceanScores? ocean;
  final VoidCallback onEditTap;

  /// Raster face for the psych-score band.
  ///
  /// Font emoji render as tofu/"bald" glyphs on several Android builds, so the
  /// score row uses the shipped PNG set instead of unicode. Bands follow
  /// [psychClassKeyForScore]: the two low bands read as sad/neutral, both
  /// healthy bands share the happy face.
  String _scoreEmojiAsset(int s) {
    final key = psychClassKeyForScore(s);
    return switch (key) {
      'butuh_perhatian' => EmotionLabelType.sad.emojiAsset,
      'rentan' => EmotionLabelType.neutral.emojiAsset,
      _ => EmotionLabelType.happy.emojiAsset,
    };
  }

  String _scoreLabel(int s, bool isEn) {
    final key = psychClassKeyForScore(s);
    if (isEn) {
      return switch (key) {
        'butuh_perhatian' => 'Needs attention',
        'rentan' => 'Vulnerable',
        'cukup_sehat' => 'Fairly healthy',
        _ => 'Healthy',
      };
    }
    return switch (key) {
      'butuh_perhatian' => 'Butuh Perhatian',
      'rentan' => 'Rentan',
      'cukup_sehat' => 'Cukup Sehat',
      _ => 'Sehat',
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final sc = score;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + AppSpacing.md.h,
        left: AppSpacing.pageX.w,
        right: AppSpacing.pageX.w,
        bottom: AppSpacing.lg.h,
      ),
      // Same brand-to-canvas wash as DiscoverHeader, so both top-level tabs
      // share one header treatment. The gradient already resolves to `canvas`
      // at the bottom, so a divider on top of it would read as a seam.
      decoration: BoxDecoration(gradient: p.brandFadeGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar bubble
              Container(
                width: 56.w,
                height: 56.w,
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

              // Name + email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.bodyStrong.copyWith(
                        color: p.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                    if (sc != null) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          EmotionEmoji(asset: _scoreEmojiAsset(sc), size: 16),
                          SizedBox(width: AppSpacing.xxs.w),
                          Text(
                            '$sc · ${_scoreLabel(sc, isEn)}',
                            style: AppTypography.label.copyWith(
                              color: p.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Edit icon
              GestureDetector(
                onTap: onEditTap,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.xs.w),
                  decoration: BoxDecoration(
                    // Matches the DiscoverHeader segmented-track alphas: keeps
                    // the gradient readable through the chrome instead of
                    // punching an opaque patch into it.
                    color: p.surface1.withValues(alpha: p.isDark ? 0.34 : 0.62),
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

          // OCEAN trait pills
          if (ocean != null) ...[
            SizedBox(height: AppSpacing.md.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: OceanTrait.values.map((t) {
                  final level = ocean!.levelOf(t);
                  return Container(
                    margin: EdgeInsets.only(right: AppSpacing.xs.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm.w,
                      vertical: AppSpacing.xxs.h + 1,
                    ),
                    decoration: BoxDecoration(
                      color: p.surface1.withValues(
                        alpha: p.isDark ? 0.34 : 0.62,
                      ),
                      borderRadius: AppRadius.chip,
                      border: Border.all(
                        color: p.primaryFill.withValues(alpha: 0.2),
                        width: AppBorder.thin,
                      ),
                    ),
                    child: Text(
                      '${t.code} ${ocean!.scoreOf(t).toStringAsFixed(1)} · ${isEn ? level.labelEn : level.labelId}',
                      style: AppTypography.caption.copyWith(
                        color: p.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Settings Section ─────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Icon(icon, color: p.textPrimary, size: 11.sp),
            ),
            SizedBox(width: AppSpacing.xs.w),
            Text(
              title,
              style: AppTypography.label.copyWith(color: p.textSecondary),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xs.h),
        Container(
          decoration: BoxDecoration(
            color: p.surface1,
            borderRadius: AppRadius.card,
            border: Border.all(color: p.divider, width: AppBorder.thin),
            boxShadow: [
              BoxShadow(
                color: p.shadowRaised,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: children.asMap().entries.map((entry) {
              final isLast = entry.key == children.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    Divider(color: p.divider, height: 1, indent: 56.w),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Settings Tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.chip,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;

  /// Icon-chip color family, assigned by row category (DESIGN.md §4).
  final IconChipFamily chip;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDestructive = chip == IconChipFamily.error;
    final labelColor = isDestructive ? p.errorText : p.textPrimary;

    return ListTile(
      leading: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: p.iconChipFill(chip),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: p.iconChipIcon(chip), size: 16.sp),
      ),
      title: Text(label, style: AppTypography.body.copyWith(color: labelColor)),
      trailing:
          trailing ??
          Icon(Icons.chevron_right_rounded, color: p.textTertiary, size: 18.sp),
      onTap: onTap,
      minLeadingWidth: 0,
    );
  }
}

// ── Privacy Switch ────────────────────────────────────────────────────────────

class _PrivacySwitch extends StatelessWidget {
  const _PrivacySwitch({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.chip,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// Privacy toggles are preference rows (DESIGN.md §4).
  final IconChipFamily chip;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SwitchListTile(
      secondary: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: p.iconChipFill(chip),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: p.iconChipIcon(chip), size: 16.sp),
      ),
      title: Text(
        label,
        style: AppTypography.body.copyWith(color: p.textPrimary),
      ),
      value: value,
      activeThumbColor: p.onPrimary,
      activeTrackColor: p.primaryFill,
      inactiveThumbColor: p.textTertiary,
      inactiveTrackColor: p.divider,
      onChanged: onChanged,
    );
  }
}

// ── Value Badge ───────────────────────────────────────────────────────────────

class _ValueBadge extends StatelessWidget {
  const _ValueBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: AppSpacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        text,
        style: AppTypography.label.copyWith(color: p.textSecondary),
      ),
    );
  }
}
