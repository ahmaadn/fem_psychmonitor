import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/profile_viewmodel.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

Future<bool> savePendingOnboardingResults(BuildContext context) async {
  final questionnaireVm = context.read<QuestionnaireViewModel>();
  if (!questionnaireVm.hasUnsavedOnboardingResults) return false;

  final authVm = context.read<AuthViewModel>();
  final profileVm = context.read<ProfileViewModel>();
  final l10n = AppLocalizations.of(context)!;
  var user = authVm.currentUser ?? profileVm.user;
  if (user == null) return false;

  final updatedUser = user.copyWith(
    mbtiResult: questionnaireVm.finalMbti ?? user.mbtiResult,
    psychScore: questionnaireVm.psychScore ?? user.psychScore,
    psychClass:
        questionnaireVm.psychClass?.classLevel.toString() ?? user.psychClass,
  );

  final saved = await profileVm.updateProfile(updatedUser, l10n);
  if (saved) {
    questionnaireVm.markOnboardingResultsSaved();
  }
  return saved;
}
