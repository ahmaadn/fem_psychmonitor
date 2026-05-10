import 'package:fem_psychmonitor/app/config/app_theme.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/data/repositories/auth_repository.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/user_repository.dart';
import 'package:fem_psychmonitor/data/repositories/dummy/dummy_auth_repository.dart';
import 'package:fem_psychmonitor/data/repositories/dummy/dummy_detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/dummy/dummy_user_repository.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/detection_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/history_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/home_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/profile_viewmodel.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:fem_psychmonitor/app/routes/app_routes.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved locale before app starts
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  // ── Repository Setup ────────────────────────────────────────────────────
  // Swap these with real implementations (SQLite / API) when ready.
  final authRepo = DummyAuthRepository();
  final detectionRepo = DummyDetectionRepository();
  final userRepo = DummyUserRepository();

  // ── ViewModel Setup ─────────────────────────────────────────────────────
  final authViewModel = AuthViewModel(authRepo: authRepo);
  final homeViewModel = HomeViewModel(detectionRepo: detectionRepo);
  final historyViewModel = HistoryViewModel(detectionRepo: detectionRepo);
  final profileViewModel = ProfileViewModel(userRepo: userRepo);
  final detectionViewModel = DetectionViewModel(detectionRepo: detectionRepo);

  runApp(
    MultiProvider(
      providers: [
        // ── Existing Providers ──
        ChangeNotifierProvider(create: (_) => EmotionDetector()..init()),
        ChangeNotifierProvider(
          create: (_) => QuestionnaireViewModel()..initData(),
        ),
        ChangeNotifierProvider.value(value: localeProvider),

        // ── Repository Providers (for direct access if needed) ──
        Provider<AuthRepository>.value(value: authRepo),
        Provider<DetectionRepository>.value(value: detectionRepo),
        Provider<UserRepository>.value(value: userRepo),

        // ── ViewModel Providers ──
        ChangeNotifierProvider.value(value: authViewModel),
        ChangeNotifierProvider.value(value: homeViewModel),
        ChangeNotifierProvider.value(value: historyViewModel),
        ChangeNotifierProvider.value(value: profileViewModel),
        ChangeNotifierProvider.value(value: detectionViewModel),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Aura Echo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
          // LOCALIZATION SETUP
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', 'US'), Locale('id', 'ID')],
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: widget!,
            );
          },
        );
      },
    );
  }
}
