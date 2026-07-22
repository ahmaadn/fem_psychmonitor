import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/voiceprint_orb.dart';
import 'package:fem_psychmonitor/features/auth/widgets/auth_footer_prompt.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: p.canvas,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: p.inkMuted,
            size: 22.sp,
          ),
          onPressed: () => _goBack(context),
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: p.canvasGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 8.h),
                const VoiceprintOrb(mode: VoiceprintMode.idle, size: 140),
                SizedBox(height: 24.h),
                Text(
                  l10n.resetPassword,
                  textAlign: TextAlign.center,
                  style: AppTypography.displayMd.copyWith(
                    fontSize: 28.0,
                    color: p.ink,
                  ),
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: 300.w,
                  child: Text(
                    'Reset password via email belum tersedia di mode offline. '
                    'Jika Anda masih login di perangkat ini, gunakan Ganti password di Pengaturan. '
                    'Jika tidak, hubungi dukungan atau buat akun baru.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.55,
                      color: p.inkMuted,
                    ),
                  ),
                ),
                SizedBox(height: 28.h),
                PrimaryButton(
                  text: l10n.back,
                  onPressed: () => context.goNamed(RouteNames.login),
                ),
                SizedBox(height: 24.h),
                Center(
                  child: AuthFooterPrompt(
                    text: l10n.rememberPassword,
                    linkText: l10n.signInHere,
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed(RouteNames.login);
                      }
                    },
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
