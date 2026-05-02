import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom sheet syarat dan ketentuan penggunaan.
/// Panggil dengan: `TermsSheet.show(context);`
class TermsSheet extends StatelessWidget {
  const TermsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TermsSheet(),
    );
  }

  static const List<_TermsSection> _sections = [
    _TermsSection(
      title: '1. Penerimaan Ketentuan',
      content:
          'Dengan menggunakan aplikasi FemPsychMonitor ("Aplikasi"), Anda menyetujui untuk terikat oleh Syarat dan Ketentuan ini. Jika Anda tidak menyetujui ketentuan ini, harap jangan gunakan Aplikasi.',
    ),
    _TermsSection(
      title: '2. Penggunaan Aplikasi',
      content:
          'Aplikasi ini dirancang sebagai alat pemantauan kesehatan emosional yang bersifat pendukung (supportive), bukan pengganti saran medis profesional. Pengguna diharapkan berusia minimal 17 tahun atau mendapatkan izin dari orang tua/wali.',
    ),
    _TermsSection(
      title: '3. Privasi dan Data',
      content:
          'Kami mengumpulkan data emosi, rekaman suara (opsional), dan data siklus yang Anda masukkan. Data ini diproses secara lokal dan/atau di server kami dengan enkripsi AES-256. Kami tidak menjual data Anda kepada pihak ketiga.',
    ),
    _TermsSection(
      title: '4. Keamanan Akun',
      content:
          'Anda bertanggung jawab menjaga kerahasiaan kredensial akun Anda. Harap segera beri tahu kami jika Anda menduga ada akses tidak sah ke akun Anda.',
    ),
    _TermsSection(
      title: '5. Batasan Layanan',
      content:
          'FemPsychMonitor bukan layanan darurat. Jika Anda mengalami krisis mental atau pikiran untuk menyakiti diri sendiri, segera hubungi layanan kesehatan jiwa atau hotline 119 ext 8.',
    ),
    _TermsSection(
      title: '6. Pembaruan Ketentuan',
      content:
          'Kami berhak memperbarui Syarat dan Ketentuan ini sewaktu-waktu. Perubahan signifikan akan diberitahukan melalui notifikasi aplikasi. Penggunaan berkelanjutan setelah perubahan berarti Anda menyetujui ketentuan yang diperbarui.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          child: Column(
            children: [
              // Drag Handle
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.md.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg.w,
                  AppSpacing.lg.h,
                  AppSpacing.lg.w,
                  AppSpacing.md.h,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDD5),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: const Color(0xFFEA580C),
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Syarat & Ketentuan', style: AppTypography.h2),
                          Text(
                            'Diperbarui 1 Januari 2024',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: AppColors.outline),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(AppSpacing.lg.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Intro notice
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: const Color(
                              0xFFEA580C,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18.sp,
                              color: const Color(0xFFEA580C),
                            ),
                            SizedBox(width: AppSpacing.sm.w),
                            Expanded(
                              child: Text(
                                'Harap baca dengan seksama sebelum menggunakan aplikasi ini.',
                                style: AppTypography.bodySm.copyWith(
                                  color: const Color(0xFFEA580C),
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      // Sections
                      ...List.generate(_sections.length, (i) {
                        final section = _sections[i];
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.lg.h),
                          child: _TermsTile(section: section),
                        );
                      }),
                      // Contact
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.mail_outline_rounded,
                                  size: 16.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: AppSpacing.xs.w),
                                Text(
                                  'Hubungi Kami',
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.sm.h),
                            Text(
                              'Jika ada pertanyaan mengenai syarat dan ketentuan ini, hubungi kami di:\nsupport@fempsychmonitor.id',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl.h),
                    ],
                  ),
                ),
              ),
              // Close button
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg.w,
                  AppSpacing.sm.h,
                  AppSpacing.lg.w,
                  AppSpacing.lg.h + MediaQuery.of(context).padding.bottom,
                ),
                child: PrimaryButton(
                  text: 'Saya Mengerti',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TermsSection {
  final String title;
  final String content;
  const _TermsSection({required this.title, required this.content});
}

class _TermsTile extends StatelessWidget {
  final _TermsSection section;
  const _TermsTile({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          section.content,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.textSecondary,
            height: 1.65,
          ),
        ),
      ],
    );
  }
}
