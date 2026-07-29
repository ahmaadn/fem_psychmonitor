import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
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

  List<_TermsSection> _buildSections(AppLocalizations l10n) => [
    _TermsSection(
      title: l10n.termsAcceptance,
      content: l10n.termsAcceptanceContent,
    ),
    _TermsSection(title: l10n.termsUsage, content: l10n.termsUsageContent),
    _TermsSection(title: l10n.termsPrivacy, content: l10n.termsPrivacyContent),
    _TermsSection(
      title: l10n.termsAccountSecurity,
      content: l10n.termsAccountSecurityContent,
    ),
    _TermsSection(
      title: l10n.termsServiceLimitations,
      content: l10n.termsServiceLimitationsContent,
    ),
    _TermsSection(title: l10n.termsUpdates, content: l10n.termsUpdatesContent),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final sections = _buildSections(l10n);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: p.surface1,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.md.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: p.divider,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
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
                        color: p.primarySoft,
                        borderRadius: AppRadius.tile,
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: p.primary,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.termsSheetTitle, style: AppTypography.subtitle),
                          Text(
                            l10n.termsUpdatedDate,
                            style: AppTypography.caption.copyWith(
                              color: p.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: p.textSecondary,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: AppBorder.thin,
                color: p.divider,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(AppSpacing.lg.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md.w),
                        decoration: p.card(
                          color: p.primarySoft,
                          borderColor: p.primary.withValues(alpha: 0.25),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18.sp,
                              color: p.primaryPressed,
                            ),
                            SizedBox(width: AppSpacing.sm.w),
                            Expanded(
                              child: Text(
                                l10n.termsReadCarefully,
                                style: AppTypography.caption.copyWith(
                                  color: p.primaryPressed,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      ...List.generate(sections.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.lg.h),
                          child: _TermsTile(section: sections[i]),
                        );
                      }),
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md.w),
                        decoration: BoxDecoration(
                          color: p.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: p.primary.withValues(alpha: 0.15),
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
                                  color: p.primary,
                                ),
                                SizedBox(width: AppSpacing.xs.w),
                                Text(
                                  l10n.contactUs,
                                  style: AppTypography.caption.copyWith(
                                    color: p.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.sm.h),
                            Text(
                              l10n.contactUsMessage,
                              style: AppTypography.caption.copyWith(
                                color: p.textSecondary,
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
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg.w,
                  AppSpacing.sm.h,
                  AppSpacing.lg.w,
                  AppSpacing.lg.h + MediaQuery.of(context).padding.bottom,
                ),
                child: PrimaryButton(
                  text: l10n.iUnderstand,
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
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          section.content,
          style: AppTypography.caption.copyWith(
            color: p.textSecondary,
            height: 1.65,
          ),
        ),
      ],
    );
  }
}
