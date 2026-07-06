import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/features/auth/pages/forgot_password_page.dart';
import 'package:fem_psychmonitor/features/history/pages/history_page.dart';
import 'package:fem_psychmonitor/features/home/pages/home_page.dart';
import 'package:fem_psychmonitor/features/auth/pages/login_page.dart';
import 'package:fem_psychmonitor/features/auth/pages/register_page.dart';
import 'package:fem_psychmonitor/features/profile/pages/profile_page.dart';
import 'package:fem_psychmonitor/features/dashboard/pages/main_layout.dart';
import 'package:fem_psychmonitor/features/recording/pages/ai_processing_page.dart';
import 'package:fem_psychmonitor/features/recording/pages/analysis_result_page.dart';
import 'package:fem_psychmonitor/features/recording/pages/live_recording_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/initial_questionnaire_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/splash_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/onboarding_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/mbti_selection_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/mbti_test_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/mbti_result_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/psych_test_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/psych_result_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Routes that require an authenticated user (US-02). The recording/teaser
/// routes are intentionally public so the guest (unauthenticated) flow can
/// reach the teaser result. Everything else (splash, onboarding, auth
/// screens) is also publicly accessible.
const Set<String> _protectedLocations = {
  '/home',
  '/history',
  '/history/analysis-result',
  '/profile',
};

class AppRouter {
  AppRouter._();

  /// Build the router, wired to [authVm] so the redirect guard re-evaluates on
  /// every auth-state change.
  static GoRouter build(AuthViewModel authVm) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authVm,
      redirect: (context, state) {
        final authenticated = authVm.isAuthenticated;
        final location = state.matchedLocation;
        final isProtected = _protectedLocations.contains(location);

        // US-02: send unauthenticated users away from protected screens.
        if (isProtected && !authenticated) {
          return '/auth/login';
        }
        // Authenticated users hitting the login/register screen bounce home.
        if (authenticated &&
            (location == '/auth/login' || location == '/auth/register')) {
          return '/home';
        }
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          name: RouteNames.splash,
          builder: (BuildContext context, GoRouterState state) {
            return const SplashPage();
          },
        ),
        GoRoute(
          path: '/onboarding',
          name: RouteNames.onboarding,
          builder: (BuildContext context, GoRouterState state) {
            final fromProfile = state.extra == true;
            return OnboardingPage(fromProfile: fromProfile);
          },
        ),
        GoRoute(
          path: '/initial-questions',
          name: RouteNames.initialQuestions,
          builder: (BuildContext context, GoRouterState state) {
            return const InitialQuestionnairePage();
          },
        ),
        GoRoute(
          path: '/mbti-selection',
          name: RouteNames.mbtiSelection,
          builder: (BuildContext context, GoRouterState state) {
            return const MbtiSelectionPage();
          },
        ),
        GoRoute(
          path: '/mbti-test',
          name: RouteNames.mbtiTest,
          builder: (BuildContext context, GoRouterState state) {
            return const MbtiTestPage();
          },
        ),
        GoRoute(
          path: '/mbti-result',
          name: RouteNames.mbtiResult,
          builder: (BuildContext context, GoRouterState state) {
            return const MbtiResultPage();
          },
        ),
        GoRoute(
          path: '/psych-test',
          name: RouteNames.psychTest,
          builder: (BuildContext context, GoRouterState state) {
            return const PsychTestPage();
          },
        ),
        GoRoute(
          path: '/psych-result',
          name: RouteNames.psychResult,
          builder: (BuildContext context, GoRouterState state) {
            return const PsychResultPage();
          },
        ),
        GoRoute(
          path: '/auth/register',
          name: RouteNames.register,
          builder: (BuildContext context, GoRouterState state) {
            final returnTo = state.extra is String
                ? state.extra as String
                : null;
            return RegisterPage(returnTo: returnTo);
          },
        ),
        GoRoute(
          path: '/auth/login',
          name: RouteNames.login,
          builder: (BuildContext context, GoRouterState state) {
            final returnTo = state.extra is String
                ? state.extra as String
                : null;
            return LoginPage(returnTo: returnTo);
          },
        ),
        GoRoute(
          path: '/auth/forgot-password',
          name: RouteNames.forgotPassword,
          builder: (BuildContext context, GoRouterState state) {
            return const ForgotPasswordPage();
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainLayout(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  name: RouteNames.home,
                  builder: (BuildContext context, GoRouterState state) {
                    return HomePage();
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/history',
                  name: RouteNames.history,
                  builder: (BuildContext context, GoRouterState state) {
                    return HistoryPage();
                  },
                  routes: [
                    GoRoute(
                      path: '/analysis-result',
                      name: RouteNames.analysisResult,
                      builder: (BuildContext context, GoRouterState state) {
                        final sessionId = state.extra is String
                            ? state.extra as String
                            : null;
                        return AnalysisResultPage(sessionId: sessionId);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  name: RouteNames.profile,
                  builder: (BuildContext context, GoRouterState state) {
                    return ProfilePage();
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: "/live-recording",
          name: RouteNames.liveRecording,
          builder: (context, state) {
            return LiveRecordingPage();
          },
        ),
        GoRoute(
          path: "/recording/processing",
          name: RouteNames.recordingProcessing,
          builder: (context, state) {
            final uploadedPath = state.extra is String
                ? state.extra as String
                : null;
            return AiProcessingPage(uploadedAudioPath: uploadedPath);
          },
        ),
        GoRoute(
          path: '/recording/analysis-teaser',
          name: RouteNames.analysisResultTeaser,
          builder: (context, state) {
            return AnalysisResultPage(isTeaser: true);
          },
        ),
      ],
    );
  }
}
