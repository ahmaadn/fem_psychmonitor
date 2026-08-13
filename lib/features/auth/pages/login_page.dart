import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/app_logo.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/features/auth/widgets/auth_footer_prompt.dart';
import 'package:fem_psychmonitor/features/onboarding/utils/onboarding_result_persistence.dart';
import 'package:fem_psychmonitor/app/widgets/custom_text_field.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final String? returnTo;
  const LoginPage({super.key, this.returnTo});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final authVm = context.read<AuthViewModel>();
    final success = await authVm.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      await savePendingOnboardingResults(context);
      if (!mounted) return;
      if (widget.returnTo != null && widget.returnTo!.isNotEmpty) {
        context.goNamed(widget.returnTo!);
      } else if (!authVm.hasCompletedAssessment) {
        context.goNamed(RouteNames.oceanTest);
      } else {
        context.goNamed(RouteNames.dashboard);
      }
    } else if (authVm.error != null) {
      final palette = context.palette;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVm.error!),
          backgroundColor: palette.warning,
        ),
      );
      authVm.clearError();
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(RouteNames.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final authVm = context.watch<AuthViewModel>();
    return Scaffold(
      backgroundColor: p.canvas,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: p.textSecondary,
            size: 22.sp,
          ),
          onPressed: _goBack,
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(color: p.canvas),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageX.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.xs.h),
                const AppLogo(size: 120),
                SizedBox(height: AppSpacing.sm.h),
                Text(
                  l10n.appName,
                  textAlign: TextAlign.center,
                  style: AppTypography.subtitle.copyWith(
                    color: p.primaryText,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: AppSpacing.xl.h),
                Text(
                  l10n.welcomeBack,
                  textAlign: TextAlign.center,
                  style: AppTypography.display.copyWith(color: p.textPrimary),
                ),
                SizedBox(height: AppSpacing.xs.h),
                SizedBox(
                  width: 280.w,
                  child: Text(
                    l10n.continueCheckin,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: p.textSecondary,
                      height: 1.55,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xxl.h - 4.h),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: l10n.email,
                        hintText: l10n.emailHint,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty) return l10n.fieldRequired;
                          if (!_emailRegex.hasMatch(value)) {
                            return l10n.emailInvalid;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.sm.h + 2.h),
                      CustomTextField(
                        label: l10n.password,
                        hintText: l10n.passwordHint,
                        isPassword: true,
                        controller: _passwordController,
                        validator: (v) => (v == null || v.isEmpty)
                            ? l10n.fieldRequired
                            : null,
                        trailingLabel: GestureDetector(
                          onTap: () =>
                              context.pushNamed(RouteNames.forgotPassword),
                          child: Text(
                            l10n.forgotPasswordQ,
                            style: AppTypography.bodyStrong.copyWith(
                              color: p.primaryText,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl.h),
                      PrimaryButton(
                        text: l10n.signIn,
                        onPressed: _handleLogin,
                        isLoading: authVm.isLoading,
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      SecondaryButton(
                        text: l10n.continueAsGuest,
                        textColor: p.primaryText,
                        borderColor: p.primary,
                        onPressed: () async {
                          final ok = await authVm.continueAsGuest();
                          if (!mounted) return;
                          if (!ok) return;
                          await savePendingOnboardingResults(context);
                          if (!mounted) return;
                          if (!authVm.hasCompletedAssessment) {
                            context.goNamed(RouteNames.oceanTest);
                          } else {
                            context.goNamed(RouteNames.dashboard);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xl.h),
                Center(
                  child: AuthFooterPrompt(
                    text: l10n.noAccountYet,
                    linkText: l10n.registerLink,
                    onTap: () => context.pushNamed(RouteNames.register),
                  ),
                ),
                SizedBox(height: AppSpacing.xl.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
