import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<bool> persistOnboardingResults({
  required AuthViewModel authVm,
  required QuestionnaireViewModel questionnaireVm,
}) async {
  final user = authVm.currentUser;
  if (user == null) return false;
  if (!questionnaireVm.hasUnsavedOnboardingResults &&
      user.hasCompletedAssessment) {
    return true;
  }

  final updated = user.copyWith(
    oceanScores: questionnaireVm.oceanScores ?? user.oceanScores,
    oceanCompletedAt: questionnaireVm.oceanScores != null
        ? DateTime.now()
        : user.oceanCompletedAt,
    psychScore: questionnaireVm.psychScore ?? user.psychScore,
    psychClass: questionnaireVm.psychClassKey ?? user.psychClass,
  );

  final ok = await authVm.saveAssessment(updated);
  if (ok) questionnaireVm.markOnboardingResultsSaved();
  return ok;
}

Future<bool> savePendingOnboardingResults(BuildContext context) async {
  final authVm = context.read<AuthViewModel>();
  final questionnaireVm = context.read<QuestionnaireViewModel>();
  return persistOnboardingResults(
    authVm: authVm,
    questionnaireVm: questionnaireVm,
  );
}
