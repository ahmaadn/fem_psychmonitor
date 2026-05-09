import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final isEnglish = localeProvider.isEnglish;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg.w,
                    vertical: AppSpacing.lg.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8.r),
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
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Column(
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/logo.png',
                              width: 160.w,
                              height: 160.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: AppSpacing.lg.h),
                          Text(
                            l10n.welcomeToApp,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          SizedBox(height: AppSpacing.sm.h),
                          Text(
                            l10n.chooseSignInMethod,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            PrimaryButton(
                              text: l10n.mulai,
                              onPressed: () {
                                context.goNamed(RouteNames.mbtiSelection);
                              },
                            ),
                            SizedBox(height: AppSpacing.sm.h),
                            SizedBox(
                              width: double.infinity,
                              height: 56.h,
                              child: OutlinedButton(
                                onPressed: () {
                                  context.goNamed(RouteNames.login);
                                },
                                child: Text(
                                  l10n.signIn,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
          borderRadius: BorderRadius.circular(7.r),
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
