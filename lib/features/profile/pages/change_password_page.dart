import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/app/widgets/custom_text_field.dart';
import 'package:fem_psychmonitor/features/home/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isSaving = false;
  int _strengthLevel = 0;

  @override
  void initState() {
    super.initState();
    _newPassController.addListener(_evaluateStrength);
  }

  void _evaluateStrength() {
    final val = _newPassController.text;
    int score = 0;
    if (val.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(val)) score++;
    if (RegExp(r'[0-9]').hasMatch(val)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(val)) score++;
    setState(() => _strengthLevel = score);
  }

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSaving = false);
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                l10n.passwordChanged,
                style: AppTypography.bodyMd.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      );
      context.pop();
    }
  }

  ({String label, Color color}) get _strengthInfo {
    final l10n = AppLocalizations.of(context)!;
    switch (_strengthLevel) {
      case 0:
      case 1:
        return (label: l10n.veryWeak, color: AppColors.warning);
      case 2:
        return (label: l10n.weak, color: const Color(0xFFEA580C));
      case 3:
        return (label: l10n.medium, color: AppColors.secondary);
      default:
        return (label: l10n.strong, color: AppColors.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final info = _strengthInfo;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: l10n.changePasswordTitle,
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSpacing.lg.h),
                      Center(
                        child: Container(
                          width: 72.w,
                          height: 72.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDBEAFE),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.info,
                            size: 34.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      Center(
                        child: Text(
                          l10n.changeAccountPassword,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl.h),
                      CustomTextField(
                        label: l10n.currentPassword,
                        hintText: l10n.enterOldPassword,
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        controller: _currentPassController,
                        validator: (v) => (v == null || v.isEmpty)
                            ? l10n.passwordRequired
                            : null,
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      CustomTextField(
                        label: l10n.newPassword,
                        hintText: l10n.minCharacters,
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        controller: _newPassController,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.passwordRequired;
                          }
                          if (v.length < 8) return l10n.minCharsRequired;
                          return null;
                        },
                      ),
                      if (_newPassController.text.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.sm.h),
                        Row(
                          children: [
                            ...List.generate(4, (i) {
                              final active = i < _strengthLevel;
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: i < 3 ? 4.w : 0,
                                  ),
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.full,
                                    ),
                                    color: active
                                        ? info.color
                                        : AppColors.outline,
                                  ),
                                ),
                              );
                            }),
                            SizedBox(width: AppSpacing.sm.w),
                            Text(
                              info.label,
                              style: AppTypography.bodySm.copyWith(
                                color: info.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: AppSpacing.md.h),
                      CustomTextField(
                        label: l10n.confirmNewPassword,
                        hintText: l10n.repeatNewPassword,
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        controller: _confirmPassController,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return l10n.passwordRequired;
                          }
                          if (v != _newPassController.text) {
                            return l10n.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      InfoCard(
                        icon: Icons.info_outline_rounded,
                        title: l10n.securityTips,
                        message: l10n.securityTipsMessage,
                      ),
                      SizedBox(height: AppSpacing.xl.h),
                      PrimaryButton(
                        text: l10n.savePassword,
                        onPressed: _save,
                        isLoading: _isSaving,
                      ),
                      SizedBox(height: AppSpacing.xl.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
