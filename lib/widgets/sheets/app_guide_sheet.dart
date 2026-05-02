import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom sheet panduan penggunaan aplikasi.
/// Panggil dengan: `AppGuideSheet.show(context);`
class AppGuideSheet extends StatefulWidget {
  const AppGuideSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AppGuideSheet(),
    );
  }

  @override
  State<AppGuideSheet> createState() => _AppGuideSheetState();
}

class _AppGuideSheetState extends State<AppGuideSheet> {
  int _selectedStep = 0;

  static const List<_GuideStep> _steps = [
    // _GuideStep(
    //   icon: Icons.add_reaction_outlined,
    //   iconColor: Color(0xFFF59E0B),
    //   iconBg: Color(0xFFFEF3C7),
    //   title: 'Catat Emosi Harian',
    //   description:
    //       'Buka tab "Catat" dan pilih emosi yang kamu rasakan hari ini. Tersedia 6 kategori emosi dasar. Tambahkan catatan singkat untuk konteks lebih mendalam.',
    // ),
    _GuideStep(
      icon: Icons.mic_rounded,
      iconColor: Color(0xFF1B6B51),
      iconBg: Color(0xFFD1FAE5),
      title: 'Rekam Suara',
      description:
          'Gunakan fitur rekam suara untuk mengekspresikan perasaan secara verbal. AI kami akan menganalisis nada dan sentimen suaramu.',
    ),
    _GuideStep(
      icon: Icons.insights_rounded,
      iconColor: Color(0xFF6D5096),
      iconBg: Color(0xFFEDDCFF),
      title: 'Lihat Insight Emosi',
      description:
          'Di tab "Insight", lihat pola emosi mingguanmu dan rekomendasi self-care yang dipersonalisasi berdasarkan data pencatatanmu.',
    ),
    _GuideStep(
      icon: Icons.calendar_month_rounded,
      iconColor: Color(0xFF2563EB),
      iconBg: Color(0xFFDBEAFE),
      title: 'Pantau Siklus',
      description:
          'Hubungkan emosi dengan siklus menstruasimu. FemPsychMonitor membantu mengenali pola emosi terkait fase siklus agar kamu lebih memahami diri sendiri.',
    ),
    // _GuideStep(
    //   icon: Icons.notifications_outlined,
    //   iconColor: Color(0xFFEA580C),
    //   iconBg: Color(0xFFFFEDD5),
    //   title: 'Pengingat Harian',
    //   description:
    //       'Aktifkan pengingat agar kamu tidak lupa mencatat emosi setiap hari. Konsistensi adalah kunci untuk mendapatkan insight yang akurat.',
    // ),
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
                  AppSpacing.sm.h,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.tertiary,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Panduan Aplikasi', style: AppTypography.h2),
                          Text(
                            '${_steps.length} langkah memulai perjalananmu',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.7,
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
              // Step Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                child: Row(
                  children: List.generate(_steps.length, (i) {
                    final isSelected = _selectedStep == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedStep = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: AppSpacing.sm.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.tertiary
                              : AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: AppTypography.label.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.5,
                                  ),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              Divider(height: 1, thickness: 1, color: AppColors.outline),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(AppSpacing.lg.w),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _StepContent(
                      key: ValueKey(_selectedStep),
                      step: _steps[_selectedStep],
                      index: _selectedStep,
                    ),
                  ),
                ),
              ),
              // Navigation
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg.w,
                  AppSpacing.sm.h,
                  AppSpacing.lg.w,
                  AppSpacing.lg.h + MediaQuery.of(context).padding.bottom,
                ),
                child: Row(
                  children: [
                    if (_selectedStep > 0) ...[
                      Expanded(
                        child: SecondaryButton(
                          text: 'Sebelumnya',
                          onPressed: () => setState(() => _selectedStep--),
                          backgroundColor: AppColors.surfaceContainerHighest,
                          textColor: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md.w),
                    ],
                    Expanded(
                      child: PrimaryButton(
                        text: _selectedStep < _steps.length - 1
                            ? 'Selanjutnya'
                            : 'Selesai',
                        onPressed: () {
                          if (_selectedStep < _steps.length - 1) {
                            setState(() => _selectedStep++);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GuideStep {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;
  const _GuideStep({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
  });
}

class _StepContent extends StatelessWidget {
  final _GuideStep step;
  final int index;
  const _StepContent({super.key, required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88.w,
          height: 88.w,
          decoration: BoxDecoration(color: step.iconBg, shape: BoxShape.circle),
          child: Icon(step.icon, color: step.iconColor, size: 44.sp),
        ),
        SizedBox(height: AppSpacing.lg.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: step.iconBg,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            'Langkah ${index + 1} dari 5',
            style: AppTypography.bodySm.copyWith(
              color: step.iconColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md.h),
        Text(step.title, style: AppTypography.h2, textAlign: TextAlign.center),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          step.description,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.textSecondary,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
