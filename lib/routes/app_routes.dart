import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/pages/auth/forgot_password_page.dart';
import 'package:fem_psychmonitor/pages/main/history_page.dart';
import 'package:fem_psychmonitor/pages/main/home_page.dart';
import 'package:fem_psychmonitor/pages/auth/login_page.dart';
import 'package:fem_psychmonitor/pages/auth/register_page.dart';
import 'package:fem_psychmonitor/pages/main_layout.dart';
import 'package:fem_psychmonitor/pages/recording/ai_processing_page.dart';
import 'package:fem_psychmonitor/pages/recording/live_recording_page.dart';
import 'package:fem_psychmonitor/pages/splash_page.dart';
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
        path: '/auth/register',
        name: RouteNames.register,
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterPage();
        },
      ),
      GoRoute(
        path: '/auth/login',
        name: RouteNames.login,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordPage();
        },
      ),
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return Scaffold(
            body: PageView(
              controller: PageController(
                initialPage: navigationShell.currentIndex,
              ),
              onPageChanged: (index) {
                navigationShell.goBranch(index);
              },
              children: children,
            ),
          );
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
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: RouteNames.profile,
                builder: (BuildContext context, GoRouterState state) {
                  return HomePage();
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
          return AiProcessingPage();
        },
      ),
    ],
  );
}
