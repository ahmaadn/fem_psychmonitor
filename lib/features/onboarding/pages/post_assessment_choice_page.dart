import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/features/onboarding/utils/onboarding_result_persistence.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Shown after assessment when user started from onboarding "Start app"
/// without being signed in yet.
class PostAssessmentChoicePage extends StatefulWidget {
  const PostAssessmentChoicePage({super.key});

  @override
  State<PostAssessmentChoicePage> createState() =>
      _PostAssessmentChoicePageState();
}

class _PostAssessmentChoicePageState extends State<PostAssessmentChoicePage> {
  bool _busy = false;

  Future<void> _asGuest() async {
    setState(() => _busy = true);
    final auth = context.read<AuthViewModel>();
    final q = context.read<QuestionnaireViewModel>();
    final ok = await auth.continueAsGuest();
    if (!mounted) return;
    if (ok) {
      await persistOnboardingResults(authVm: auth, questionnaireVm: q);
    }
    if (!mounted) return;
    setState(() => _busy = false);
    context.goNamed(RouteNames.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isEn = context.watch<LocaleProvider>().isEnglish;
    return Scaffold(
      backgroundColor: p.canvas,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: p.canvasGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(
                  isEn ? 'Almost there' : 'Hampir selesai',
                  style: AppTypography.displayMd.copyWith(
                    fontSize: 28.sp,
                    color: p.ink,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  isEn
                      ? 'Save your assessment as a guest or create an account.'
                      : 'Simpan hasil asesmen sebagai tamu atau buat akun.',
                  style: AppTypography.body.copyWith(color: p.inkMuted),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                PrimaryButton(
                  text: isEn ? 'Continue as guest' : 'Lanjut sebagai tamu',
                  isLoading: _busy,
                  onPressed: _asGuest,
                ),
                SizedBox(height: 12.h),
                SecondaryButton(
                  text: isEn ? 'Create account' : 'Buat akun',
                  onPressed: () => context.pushNamed(RouteNames.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
