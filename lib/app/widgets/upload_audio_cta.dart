import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// CTA unggah rekaman suara dari penyimpanan perangkat.
///
/// Aksi sekunder terhadap voice check-in langsung, sehingga memakai keluarga
/// warna Matcha (secondary) dengan permukaan tonal — bukan fill brand penuh —
/// agar tetap satu tingkat di bawah tombol primer di atasnya (DESIGN.md §4).
/// Teks/ikon memakai [AppPalette.secondaryText] (step -700 light / -300 dark),
/// bukan seed `-500`, sesuai aturan ramp-step.
class UploadAudioCta extends StatelessWidget {
  const UploadAudioCta({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLoading = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Menampilkan spinner dan menonaktifkan tap saat picker/verifikasi berjalan.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = p.secondaryText;

    return Semantics(
      button: true,
      enabled: !isLoading,
      label: title,
      hint: subtitle,
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: isLoading ? 0.7 : 1,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: AppSpacing.touch.h),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md.w,
              vertical: AppSpacing.sm.h,
            ),
            decoration: BoxDecoration(
              color: p.secondaryWash,
              borderRadius: AppRadius.card,
              border: Border.all(
                color: AppColors.secondary500.withValues(
                  alpha: p.isDark ? 0.36 : 0.28,
                ),
                width: AppBorder.medium,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.secondary500.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isLoading
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(fg),
                          ),
                        )
                      : Icon(
                          Icons.upload_file_rounded,
                          color: fg,
                          size: 20.sp,
                        ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyStrong.copyWith(color: fg),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: AppTypography.caption.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: fg.withValues(alpha: 0.7),
                  size: 14.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
