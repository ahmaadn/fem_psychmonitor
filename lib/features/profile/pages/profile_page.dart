import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/profile_viewmodel.dart';
import 'package:fem_psychmonitor/features/profile/pages/change_password_page.dart';
import 'package:fem_psychmonitor/features/profile/pages/edit_profile_page.dart';
import 'package:fem_psychmonitor/features/profile/widgets/profile_menu_group.dart';
import 'package:fem_psychmonitor/features/profile/widgets/profile_menu_item.dart';
import 'package:fem_psychmonitor/features/profile/widgets/sheets/app_guide_sheet.dart';
import 'package:fem_psychmonitor/features/profile/widgets/sheets/terms_sheet.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(l10n.logout, style: AppTypography.fraunces(size: 20)),
        content: Text(
          l10n.logoutConfirmMessage,
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.confirmLogout,
              style: const TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await context.read<AuthViewModel>().logout();
    if (!mounted) return;
    context.goNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final isEnglish = localeProvider.isEnglish;
    final profileVm = context.watch<ProfileViewModel>();
    final user = profileVm.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Text(l10n.myProfile, style: AppTypography.fraunces(size: 30)),
              SizedBox(height: 20.h),
              _Header(user: user),
              SizedBox(height: 24.h),
              ProfileMenuGroup(
                items: [
                  ProfileMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: l10n.editProfile,
                    iconColor: AppColors.primary,
                    iconBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.12,
                    ),
                    onTap: () async {
                      final vm = context.read<ProfileViewModel>();
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      );
                      if (mounted) vm.loadProfile();
                    },
                    showBorder: true,
                  ),
                  ProfileMenuItem(
                    icon: Icons.lock_outline_rounded,
                    title: l10n.changePassword,
                    iconColor: AppColors.info,
                    iconBackgroundColor: AppColors.infoSurface,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordPage(),
                      ),
                    ),
                    showBorder: false,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ProfileMenuGroup(
                items: [
                  ProfileMenuItem(
                    icon: Icons.language_rounded,
                    title: l10n.language,
                    iconColor: AppColors.primary,
                    iconBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.12,
                    ),
                    trailing: _LangTabs(isEnglish: isEnglish),
                    showBorder: false,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ProfileMenuGroup(
                items: [
                  ProfileMenuItem(
                    icon: Icons.menu_book_rounded,
                    title: l10n.appGuide,
                    iconColor: AppColors.tertiary,
                    iconBackgroundColor: AppColors.tertiary.withValues(
                      alpha: 0.14,
                    ),
                    onTap: () => AppGuideSheet.show(context),
                    showBorder: true,
                  ),
                  ProfileMenuItem(
                    icon: Icons.description_outlined,
                    title: l10n.termsAndConditions,
                    iconColor: AppColors.secondary,
                    iconBackgroundColor: AppColors.secondary.withValues(
                      alpha: 0.16,
                    ),
                    onTap: () => TermsSheet.show(context),
                    showBorder: true,
                  ),
                  ProfileMenuItem(
                    icon: Icons.verified_user_outlined,
                    title: l10n.licenses,
                    iconColor: AppColors.textSecondary,
                    iconBackgroundColor: AppColors.surfaceContainerHighest,
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'Aura Echo',
                      applicationVersion: '1.0.0',
                      applicationLegalese: l10n.licenseLegalese,
                    ),
                    showBorder: true,
                  ),
                  ProfileMenuItem(
                    icon: Icons.rocket_launch_outlined,
                    title: l10n.goOnBoarding,
                    iconColor: AppColors.tertiary,
                    iconBackgroundColor: AppColors.tertiary.withValues(
                      alpha: 0.14,
                    ),
                    onTap: () =>
                        context.pushNamed(RouteNames.onboarding, extra: true),
                    showBorder: false,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ProfileMenuGroup(
                items: [
                  ProfileMenuItem(
                    icon: Icons.logout_rounded,
                    title: l10n.logout,
                    iconColor: AppColors.warning,
                    iconBackgroundColor: AppColors.warningSurface,
                    isDestructive: true,
                    onTap: _handleLogout,
                    showBorder: false,
                  ),
                ],
              ),
              SizedBox(height: 120.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Header card ─────────────────────────
class _Header extends StatelessWidget {
  final dynamic user; // UserModel?
  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time_filled_rounded,
                      size: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 5.w),
                    Flexible(
                      child: Text(
                        user != null
                            ? '${l10n.joinedSince} ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                            : l10n.joinedSince,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  user?.fullName ?? '...',
                  style: AppTypography.fraunces(
                    size: 20,
                    weight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        user?.email ?? '...',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LangTabs extends StatelessWidget {
  final bool isEnglish;
  const _LangTabs({required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(9999.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tab(
            context,
            'ID',
            !isEnglish,
            () => context.read<LocaleProvider>().switchToIndonesian(),
          ),
          _tab(
            context,
            'EN',
            isEnglish,
            () => context.read<LocaleProvider>().switchToEnglish(),
          ),
        ],
      ),
    );
  }

  Widget _tab(BuildContext ctx, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9999.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: active
                ? Colors.white
                : AppColors.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
