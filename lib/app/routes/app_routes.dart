import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/features/auth/pages/forgot_password_page.dart';
import 'package:fem_psychmonitor/features/auth/pages/login_page.dart';
import 'package:fem_psychmonitor/features/auth/pages/register_page.dart';
import 'package:fem_psychmonitor/features/dashboard/pages/main_layout.dart';
import 'package:fem_psychmonitor/features/discover/pages/discover_page.dart';
import 'package:fem_psychmonitor/features/home/pages/home_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/ocean_result_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/ocean_test_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/onboarding_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/post_assessment_choice_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/psych_result_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/psych_test_page.dart';
import 'package:fem_psychmonitor/features/onboarding/pages/splash_page.dart';
import 'package:fem_psychmonitor/features/profile/pages/change_password_page.dart';
import 'package:fem_psychmonitor/features/profile/pages/edit_profile_page.dart';
import 'package:fem_psychmonitor/features/recording/pages/ai_processing_page.dart';
import 'package:fem_psychmonitor/features/recording/pages/analysis_result_page.dart';
import 'package:fem_psychmonitor/features/recording/pages/live_recording_page.dart';
import 'package:fem_psychmonitor/features/settings/pages/settings_page.dart';
import 'package:go_router/go_router.dart';

const Set<String> _shellLocations = {
  '/dashboard',
  '/discover',
  '/discover/analysis-result',
  '/settings',
  '/settings/edit-profile',
  '/settings/change-password',
};

class AppRouter {
  AppRouter._();

  static GoRouter build(AuthViewModel authVm) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authVm,
      redirect: (context, state) {
        final authed = authVm.isAuthenticated;
        final assessed = authVm.hasCompletedAssessment;
        final loc = state.matchedLocation;

        final isPublic =
            loc == '/' ||
            loc == '/onboarding' ||
            loc.startsWith('/auth') ||
            loc.startsWith('/ocean') ||
            loc.startsWith('/psych') ||
            loc == '/post-assessment-choice';

        final isShell =
            _shellLocations.contains(loc) ||
            loc.startsWith('/discover') ||
            loc == '/live-recording' ||
            loc.startsWith('/recording');

        if (!authed && isShell) {
          return '/onboarding';
        }

        if (authed &&
            (loc == '/auth/login' || loc == '/auth/register') &&
            assessed) {
          return '/dashboard';
        }

        if (authed &&
            !assessed &&
            (loc == '/dashboard' ||
                loc == '/discover' ||
                loc.startsWith('/settings'))) {
          return '/ocean-test';
        }

        if (authed && assessed && loc == '/onboarding') {
          return '/dashboard';
        }

        if (!isPublic && !authed) {
          return '/onboarding';
        }

        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          name: RouteNames.splash,
          builder: (_, _) => const SplashPage(),
        ),
        GoRoute(
          path: '/onboarding',
          name: RouteNames.onboarding,
          builder: (_, state) {
            final fromProfile = state.extra == true;
            return OnboardingPage(fromProfile: fromProfile);
          },
        ),
        GoRoute(
          path: '/ocean-test',
          name: RouteNames.oceanTest,
          builder: (_, _) => const OceanTestPage(),
        ),
        GoRoute(
          path: '/ocean-result',
          name: RouteNames.oceanResult,
          builder: (_, _) => const OceanResultPage(),
        ),
        GoRoute(
          path: '/psych-test',
          name: RouteNames.psychTest,
          builder: (_, _) => const PsychTestPage(),
        ),
        GoRoute(
          path: '/psych-result',
          name: RouteNames.psychResult,
          builder: (_, _) => const PsychResultPage(),
        ),
        GoRoute(
          path: '/post-assessment-choice',
          name: RouteNames.postAssessmentChoice,
          builder: (_, _) => const PostAssessmentChoicePage(),
        ),
        GoRoute(
          path: '/auth/register',
          name: RouteNames.register,
          builder: (_, state) {
            final returnTo = state.extra is String
                ? state.extra as String
                : null;
            return RegisterPage(returnTo: returnTo);
          },
        ),
        GoRoute(
          path: '/auth/login',
          name: RouteNames.login,
          builder: (_, state) {
            final returnTo = state.extra is String
                ? state.extra as String
                : null;
            return LoginPage(returnTo: returnTo);
          },
        ),
        GoRoute(
          path: '/auth/forgot-password',
          name: RouteNames.forgotPassword,
          builder: (_, _) => const ForgotPasswordPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainLayout(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/dashboard',
                  name: RouteNames.dashboard,
                  builder: (_, _) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/discover',
                  name: RouteNames.discover,
                  builder: (_, _) => const DiscoverPage(),
                  routes: [
                    GoRoute(
                      path: 'analysis-result',
                      name: RouteNames.analysisResult,
                      builder: (_, state) {
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
                  path: '/settings',
                  name: RouteNames.settings,
                  builder: (_, _) => const SettingsPage(),
                  routes: [
                    GoRoute(
                      path: 'edit-profile',
                      name: RouteNames.editProfile,
                      builder: (_, _) => const EditProfilePage(),
                    ),
                    GoRoute(
                      path: 'change-password',
                      name: RouteNames.changePassword,
                      builder: (_, _) => const ChangePasswordPage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(path: '/profile', redirect: (_, _) => '/settings'),
        GoRoute(
          path: '/live-recording',
          name: RouteNames.liveRecording,
          builder: (_, _) => const LiveRecordingPage(),
        ),
        GoRoute(
          path: '/recording/processing',
          name: RouteNames.recordingProcessing,
          builder: (_, state) {
            final uploadedPath = state.extra is String
                ? state.extra as String
                : null;
            return AiProcessingPage(uploadedAudioPath: uploadedPath);
          },
        ),
        GoRoute(
          path: '/recording/analysis-teaser',
          name: RouteNames.analysisResultTeaser,
          builder: (_, _) => const AnalysisResultPage(isTeaser: true),
        ),
        // Legacy path aliases
        GoRoute(path: '/home', redirect: (_, _) => '/dashboard'),
        GoRoute(path: '/history', redirect: (_, _) => '/discover'),
      ],
    );
  }
}
