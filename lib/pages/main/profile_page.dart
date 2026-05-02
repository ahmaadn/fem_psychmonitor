import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/pages/profile/change_password_page.dart';
import 'package:fem_psychmonitor/pages/profile/edit_profile_page.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/widgets/profile_menu_group.dart';
import 'package:fem_psychmonitor/widgets/profile_menu_item.dart';
import 'package:fem_psychmonitor/widgets/sheets/app_guide_sheet.dart';
import 'package:fem_psychmonitor/widgets/sheets/terms_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // State untuk switch Bahasa
  bool _isEnglish = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Profil Saya', showBackButton: false),
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
                              // Avatar + Status Dot
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
                                        color: Colors.grey.shade500,
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

                              // Edit Profile Button
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
                                  'Edit Image',
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

                          // Time / Join Date
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
                                'Bergabung sejak Januari 2024',
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

                          // Name
                          Text(
                            'Adinda Larasati',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          SizedBox(height: 8.h),

                          // Subtitle / Email
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
                                'adinda.larasati@email.com',
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

                    // ==========================================
                    // MENU: PROFIL & KEAMANAN
                    // ==========================================
                    ProfileMenuGroup(
                      items: [
                        ProfileMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: 'Ubah Profil',
                          iconColor: AppColors.primary,
                          iconBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          ),
                          showBorder: true,
                        ),
                        ProfileMenuItem(
                          icon: Icons.lock_outline_rounded,
                          title: 'Ganti Password',
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

                    // ==========================================
                    // MENU: PENGATURAN APLIKASI
                    // ==========================================
                    ProfileMenuGroup(
                      items: [
                        ProfileMenuItem(
                          icon: Icons.language_rounded,
                          title: 'Bahasa',
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
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isEnglish = false;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !_isEnglish
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm - 1,
                                      ),
                                    ),
                                    child: Text(
                                      'ID',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: !_isEnglish
                                                ? Colors.white
                                                : AppColors.primary.withValues(
                                                    alpha: 0.6,
                                                  ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isEnglish = true;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isEnglish
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm - 1,
                                      ),
                                    ),
                                    child: Text(
                                      'EN',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: _isEnglish
                                                ? Colors.white
                                                : AppColors.primary.withValues(
                                                    alpha: 0.6,
                                                  ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          showBorder: false,
                        ),
                      ],
                    ),

                    // ==========================================
                    // MENU: BANTUAN & INFORMASI
                    // ==========================================
                    ProfileMenuGroup(
                      items: [
                        ProfileMenuItem(
                          icon: Icons.menu_book_rounded,
                          title: 'Panduan Aplikasi',
                          iconColor: AppColors.tertiary,
                          iconBackgroundColor: AppColors.tertiary.withValues(
                            alpha: 0.1,
                          ),
                          onTap: () => AppGuideSheet.show(context),
                          showBorder: true,
                        ),
                        ProfileMenuItem(
                          icon: Icons.description_outlined,
                          title: 'Syarat dan Ketentuan',
                          iconColor: const Color(0xFFEA580C),
                          iconBackgroundColor: const Color(0xFFFFEDD5),
                          onTap: () => TermsSheet.show(context),
                          showBorder: true,
                        ),
                        ProfileMenuItem(
                          icon: Icons.verified_user_outlined,
                          title: 'Lisensi',
                          iconColor: const Color(0xFF475569),
                          iconBackgroundColor: const Color(0xFFF1F5F9),
                          onTap: () => showLicensePage(
                            context: context,
                            applicationName: 'FemPsychMonitor',
                            applicationVersion: '1.0.0',
                            applicationLegalese:
                                '© 2024 FemPsychMonitor. Hak cipta dilindungi undang-undang.',
                          ),
                          showBorder: true,
                        ),
                        ProfileMenuItem(
                          icon: Icons.rocket_launch_outlined,
                          title: 'Go On Boarding',
                          iconColor: const Color(0xFF4F46E5),
                          iconBackgroundColor: const Color(0xFFE0E7FF),
                          onTap: () {},
                          showBorder: false,
                        ),
                      ],
                    ),

                    // ==========================================
                    // MENU: LOGOUT
                    // ==========================================
                    ProfileMenuGroup(
                      items: [
                        ProfileMenuItem(
                          icon: Icons.logout_rounded,
                          title: 'Keluar',
                          iconColor: const Color(0xFFDC2626),
                          iconBackgroundColor: const Color(0xFFFEE2E2),
                          isDestructive: true,
                          onTap: () {},
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
}
