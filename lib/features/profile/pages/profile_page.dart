import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/profile_viewmodel.dart';
import 'package:fem_psychmonitor/features/profile/pages/change_password_page.dart';
import 'package:fem_psychmonitor/features/profile/pages/edit_profile_page.dart';
import 'package:fem_psychmonitor/app/widgets/custom_app_bar.dart';
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
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(l10n.logout),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
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
      appBar: CustomAppBar(title: l10n.myProfile, showBackButton: false),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    Container(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.outline, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 64.w,
                                    height: 64.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerHighest,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: AppColors.outline,
                                        size: 40.sp,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 4,
                                    child: Container(
                                      width: 14.w,
                                      height: 14.w,
                                      decoration: BoxDecoration(
                                        color: user != null
                                            ? Colors.green
                                            : Colors.grey.shade500,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.surface,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.full,
                                  ),
                                  border: Border.all(color: AppColors.outline),
                                ),
                                child: Text(
                                  l10n.editImage,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_filled_rounded,
                                size: 14.sp,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                user != null
                                    ? '${l10n.joinedSince} ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                                    : l10n.joinedSince,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            user?.fullName ?? '...',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                user?.email ?? '...',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontSize: 13.sp,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    ProfileMenuGroup(
                      items: [
                        ProfileMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: l10n.editProfile,
                          iconColor: AppColors.primary,
                          iconBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EditProfilePage(),
                              ),
                            );
                            // Reload profile after editing
                            if (mounted) {
                              context.read<ProfileViewModel>().loadProfile();
                            }
                          },
                          showBorder: true,
                        ),
                        ProfileMenuItem(
                          icon: Icons.lock_outline_rounded,
                          title: l10n.changePassword,
                          iconColor: const Color(0xFF2563EB),
                          iconBackgroundColor: const Color(0xFFDBEAFE),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordPage(),
                            ),
                          ),
                          showBorder: false,
                        ),
                      ],
                    ),
                    ProfileMenuGroup(
                      items: [
                        ProfileMenuItem(
                          icon: Icons.language_rounded,
                          title: l10n.language,
                          iconColor: const Color(0xFF059669),
                          iconBackgroundColor: const Color(0xFFD1FAE5),
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _langTab(context, 'ID', !isEnglish, () {
                                  context.read<LocaleProvider>().switchToIndonesian();
                                }),
                                _langTab(context, 'EN', isEnglish, () {
                                  context.read<LocaleProvider>().switchToEnglish();
                                }),
                              ],
                            ),
                          ),
                          showBorder: false,
                        ),
                      ],
                    ),
                    ProfileMenuGroup(
                      items: [
                        ProfileMenuItem(
                          icon: Icons.menu_book_rounded,
                          title: l10n.appGuide,
                          iconColor: AppColors.tertiary,
                          iconBackgroundColor: AppColors.tertiary.withValues(
                            alpha: 0.1,
                          ),
                          onTap: () => AppGuideSheet.show(context),
                          showBorder: true,
                        ),
                        ProfileMenuItem(
                          icon: Icons.description_outlined,
                          title: l10n.termsAndConditions,
                          iconColor: const Color(0xFFEA580C),
                          iconBackgroundColor: const Color(0xFFFFEDD5),
                          onTap: () => TermsSheet.show(context),
                          showBorder: true,
                        ),
                        ProfileMenuItem(
                          icon: Icons.verified_user_outlined,
                          title: l10n.licenses,
                          iconColor: const Color(0xFF475569),
                          iconBackgroundColor: const Color(0xFFF1F5F9),
                          onTap: () => showLicensePage(
                            context: context,
                            applicationName: 'FemPsychMonitor',
                            applicationVersion: '1.0.0',
                            applicationLegalese: l10n.licenseLegalese,
                          ),
                          showBorder: true,
                        ),
                        ProfileMenuItem(
                          icon: Icons.rocket_launch_outlined,
                          title: l10n.goOnBoarding,
                          iconColor: const Color(0xFF4F46E5),
                          iconBackgroundColor: const Color(0xFFE0E7FF),
                          onTap: () {},
                          showBorder: false,
                        ),
                      ],
                    ),
                    ProfileMenuGroup(
                      items: [
                        ProfileMenuItem(
                          icon: Icons.logout_rounded,
                          title: l10n.logout,
                          iconColor: const Color(0xFFDC2626),
                          iconBackgroundColor: const Color(0xFFFEE2E2),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _langTab(
    BuildContext ctx,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm - 1),
        ),
        child: Text(
          label,
          style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
            color: active
                ? Colors.white
                : AppColors.primary.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
