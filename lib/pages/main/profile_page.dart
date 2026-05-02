import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/widgets/button_widget.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // State untuk mengontrol Accordion Ganti Password
  bool _isPasswordExpanded = false;

  // State untuk menyimpan nilai dropdown Bahasa
  String _selectedLanguage = 'Indonesia';
  final List<String> _supportedLanguages = ['Indonesia', 'English'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(
                title: 'Profil Saya',
                centerTitle: true,
                showBackButton: false,
                isScrollable: true,
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 32.h),

                    // ==========================================
                    // PROFILE AVATAR
                    // ==========================================
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 110.w,
                          height: 110.w,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1E1E1E,
                            ), // Warna abu-abu gelap
                            borderRadius: BorderRadius.circular(32.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 64.sp,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColors.primary, // Trust Blue
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.background,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // ==========================================
                    // USER NAME & JOIN DATE
                    // ==========================================
                    Text(
                      'Adinda Larasati',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      'Bergabung sejak Januari 2024',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // ==========================================
                    // CARD: INFORMASI PROFIL
                    // ==========================================
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 20.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Informasi Profil',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),
                          Divider(color: Colors.grey.shade100, thickness: 1),
                          SizedBox(height: 24.h),

                          _buildProfileTextField(
                            context,
                            label: 'NAMA LENGKAP',
                            initialValue: 'Adinda Larasati',
                            suffixIcon: Icons.edit_rounded,
                          ),

                          SizedBox(height: 20.h),

                          _buildProfileTextField(
                            context,
                            label: 'ALAMAT EMAIL',
                            initialValue: 'adinda.larasati@email.com',
                            suffixIcon: Icons.lock_rounded,
                            isReadOnly: true,
                          ),

                          SizedBox(height: 32.h),

                          PrimaryButton(
                            text: 'Simpan Perubahan',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // ==========================================
                    // CARD: GANTI PASSWORD (ACCORDION)
                    // ==========================================
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 20.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        // Menyesuaikan radius saat tertutup (pill) vs saat terbuka (card)
                        borderRadius: BorderRadius.circular(
                          _isPasswordExpanded ? AppRadius.xl : AppRadius.full,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header (Clickable)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPasswordExpanded = !_isPasswordExpanded;
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: AppColors
                                        .infoSurface, // Warna ungu ringan
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.vpn_key_rounded,
                                    color: AppColors.info,
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Text(
                                    'Ganti Password',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                                // Animasi rotasi panah
                                AnimatedRotation(
                                  turns: _isPasswordExpanded ? 0.5 : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey.shade400,
                                    size: 24.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Body Accordion (Expandable Fields)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: !_isPasswordExpanded
                                ? const SizedBox.shrink()
                                : Column(
                                    children: [
                                      SizedBox(height: 24.h),
                                      _buildProfileTextField(
                                        context,
                                        label: 'PASSWORD SAAT INI',
                                        initialValue: '........',
                                        isPassword: true,
                                      ),
                                      SizedBox(height: 16.h),
                                      _buildProfileTextField(
                                        context,
                                        label: 'PASSWORD BARU',
                                        initialValue: '........',
                                        isPassword: true,
                                      ),
                                      SizedBox(height: 16.h),
                                      _buildProfileTextField(
                                        context,
                                        label: 'KONFIRMASI PASSWORD BARU',
                                        initialValue: '........',
                                        isPassword: true,
                                      ),
                                      SizedBox(height: 24.h),
                                      PrimaryButton(
                                        text: 'Simpan Perubahan',
                                        onPressed: () {
                                          // Aksi simpan password baru
                                        },
                                      ),
                                      SizedBox(height: 8.h),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // ==========================================
                    // CARD: BAHASA (DROPDOWN)
                    // ==========================================
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFE0F2FE,
                              ), // Warna hijau/teal pucat aksen
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.translate_rounded,
                              color: const Color(0xFF0369A1),
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Text(
                              'Bahasa',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          // Widget Dropdown
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 0.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedLanguage,
                                icon: Padding(
                                  padding: EdgeInsets.only(left: 8.w),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurface.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                dropdownColor: Colors.white,
                                items: _supportedLanguages.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedLanguage = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 48.h),

                    // ==========================================
                    // BUTTON: KELUAR (LOGOUT)
                    // ==========================================
                    GestureDetector(
                      onTap: () {
                        // Aksi Logout
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFE2E8F0,
                          ), // Slate 200 (Abu-abu lembut)
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: AppColors.warning,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Keluar',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.warning, // Warna merah
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 120.h,
                    ), // Ruang ekstra untuk Bottom Navigation
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- KOMPONEN: TEXT FIELD KHUSUS PROFIL ---
  Widget _buildProfileTextField(
    BuildContext context, {
    required String label,
    required String initialValue,
    IconData? suffixIcon,
    bool isReadOnly = false,
    bool isPassword = false, // Menambahkan parameter password
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface.withValues(alpha: 0.5),
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          initialValue: initialValue,
          readOnly: isReadOnly,
          obscureText:
              isPassword, // Mengamankan input berupa titik-titik (....)
          obscuringCharacter: '•',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: isReadOnly
                ? AppColors.onSurface.withValues(alpha: 0.5)
                : AppColors.onSurface,
            letterSpacing: isPassword
                ? 2.0
                : 0.0, // Jika password, beri jarak antar titik
          ),
          decoration: InputDecoration(
            fillColor: const Color(0xFFF1F5F9), // Slate 100
            filled: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: BorderSide.none,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(
                    suffixIcon,
                    color: isReadOnly
                        ? Colors.grey.shade400
                        : AppColors.onSurface.withValues(alpha: 0.5),
                    size: 20.sp,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
