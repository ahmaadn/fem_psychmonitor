import 'dart:async';

import 'package:fem_psychmonitor/app/config/app_config.dart';
import 'package:fem_psychmonitor/app/config/app_theme.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/app/providers/privacy_provider.dart';
import 'package:fem_psychmonitor/app/providers/theme_provider.dart';
import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/seed/question_seeder.dart';
import 'package:fem_psychmonitor/data/repositories/auth_repository.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/question_repository.dart';
import 'package:fem_psychmonitor/data/repositories/recommendation_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_auth_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_client.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_daily_mood_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_user_repository.dart';
import 'package:fem_psychmonitor/data/repositories/hybrid/hybrid_auth_repository.dart';
import 'package:fem_psychmonitor/data/repositories/hybrid/hybrid_detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/hybrid/hybrid_user_repository.dart';
import 'package:fem_psychmonitor/data/repositories/sqlite/sqlite_auth_repository.dart';
import 'package:fem_psychmonitor/data/repositories/sqlite/sqlite_detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/sqlite/sqlite_question_repository.dart';
import 'package:fem_psychmonitor/data/repositories/sqlite/sqlite_recommendation_repository.dart';
import 'package:fem_psychmonitor/data/repositories/sqlite/sqlite_user_repository.dart';
import 'package:fem_psychmonitor/data/repositories/user_repository.dart';
import 'package:fem_psychmonitor/data/sync/sqlite_sync_service.dart';
import 'package:fem_psychmonitor/data/sync/sync_service.dart';
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
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load intl date symbols for both supported locales so DateFormat.MMMM /
  // .E / .yMMMMd render Indonesian month and weekday names on the Discover
  // calendar instead of falling back to English.
  await initializeDateFormatting('en_US');
  await initializeDateFormatting('id_ID');

  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();
  final themeProvider = ThemeProvider();
  await themeProvider.loadSavedTheme();
  final privacyProvider = PrivacyProvider();
  await privacyProvider.load();

  await DatabaseHelper.initPlatform();
  await DatabaseHelper.instance.database;
  await QuestionSeeder.instance.seedIfEmpty();

  final sessionStore = RemoteAuthSessionStore();
  await sessionStore.load();
  final apiClient = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    sessionStore: sessionStore,
    timeout: const Duration(seconds: AppConfig.apiTimeoutSeconds),
  );
  final apiAuthRepo = ApiAuthRepository(apiClient: apiClient);
  final apiUserRepo = ApiUserRepository(apiClient: apiClient);
  final apiDetectionRepo = ApiDetectionRepository(apiClient: apiClient);
  final apiDailyMoodRepo = ApiDailyMoodRepository(apiClient: apiClient);

  final localAuthRepo = SqliteAuthRepository();
  final localDetectionRepo = SqliteDetectionRepository();
  final localUserRepo = SqliteUserRepository();
  final syncService = SqliteSyncService(
    apiAuth: apiAuthRepo,
    apiUser: apiUserRepo,
    apiDetection: apiDetectionRepo,
    apiDailyMood: apiDailyMoodRepo,
  );
  final authRepo = HybridAuthRepository(
    local: localAuthRepo,
    remote: apiAuthRepo,
    remoteUser: apiUserRepo,
    onRemoteAuthenticated: syncService.synchronize,
  );
  final userRepo = HybridUserRepository(
    local: localUserRepo,
    remote: apiUserRepo,
    onChanged: syncService.synchronize,
  );
  final questionRepo = SqliteQuestionRepository();
  final recommendationRepo = SqliteRecommendationRepository();

  final detectionRepo = HybridDetectionRepository(
    local: localDetectionRepo,
    sync: syncService,
  );
  unawaited(syncService.synchronize());

  final authViewModel = AuthViewModel(authRepo: authRepo);
  final homeViewModel = HomeViewModel(detectionRepo: detectionRepo);
  final historyViewModel = HistoryViewModel(detectionRepo: detectionRepo);
  final profileViewModel = ProfileViewModel(userRepo: userRepo);
  final detectionViewModel = DetectionViewModel(detectionRepo: detectionRepo);
  final questionnaireViewModel = QuestionnaireViewModel(
    questionRepo: questionRepo,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmotionDetector()..init()),
        ChangeNotifierProvider.value(value: questionnaireViewModel..initData()),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: privacyProvider),
        Provider<AuthRepository>.value(value: authRepo),
        Provider<DetectionRepository>.value(value: detectionRepo),
        Provider<UserRepository>.value(value: userRepo),
        Provider<QuestionRepository>.value(value: questionRepo),
        Provider<RecommendationRepository>.value(value: recommendationRepo),
        Provider<SyncService>.value(value: syncService),
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.build(context.read<AuthViewModel>());
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Fem-Psychmonitor',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.mode,
          routerConfig: _router,
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
