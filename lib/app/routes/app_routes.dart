import 'package:fem_psychmonitor/app/config/app_constants.dart';
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
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
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
          return const OnboardingPage();
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
        path: '/auth/register',
        name: RouteNames.register,
        builder: (BuildContext context, GoRouterState state) {
          final returnTo = state.extra is String ? state.extra as String : null;
          return RegisterPage(returnTo: returnTo);
        },
      ),
      GoRoute(
        path: '/auth/login',
        name: RouteNames.login,
        builder: (BuildContext context, GoRouterState state) {
          final returnTo = state.extra is String ? state.extra as String : null;
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
        // navigatorContainerBuilder: (context, navigationShell, children) {
        //   /// Implementation: https://medium.com/@danieletulone.work/building-a-swipable-stateful-navigator-shell-in-flutter-using-go-router-49ced62c2446
        //   return NavigatorContainerWithPageView(
        //     navigationShell: navigationShell,
        //     children: children,
        //   );
        // },
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
                      return AnalysisResultPage();
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
