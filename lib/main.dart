import 'package:fem_psychmonitor/app/config/app_theme.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/data/local/database_helper.dart';
import 'package:fem_psychmonitor/data/local/seed/question_seeder.dart';
import 'package:fem_psychmonitor/data/repositories/auth_repository.dart';
import 'package:fem_psychmonitor/data/repositories/detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/question_repository.dart';
import 'package:fem_psychmonitor/data/repositories/recommendation_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_auth_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_detection_repository.dart';
import 'package:fem_psychmonitor/data/repositories/api/api_user_repository.dart';
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
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved locale before app starts
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();

  // ── Offline-first SQLite bootstrap ────────────────────────────────────
  // Initialise the platform-appropriate DB factory (FFI on desktop) and open
  // the database, then seed master data from assets on first run.
  DatabaseHelper.initPlatform();
  await DatabaseHelper.instance.database;
  await QuestionSeeder.instance.seedIfEmpty();

  // ── Repository Setup (Sqlite = active layer; offline-first) ───────────
  final authRepo = SqliteAuthRepository();
  final detectionRepo = SqliteDetectionRepository();
  final userRepo = SqliteUserRepository();
  final questionRepo = SqliteQuestionRepository();
  final recommendationRepo = SqliteRecommendationRepository();

  // SyncService: API stubs are constructed but baseUrl is null, so push/pull
  // are guarded no-ops until a live server is configured.
  final syncService = SqliteSyncService(
    apiAuth: ApiAuthRepository(),
    apiUser: ApiUserRepository(),
    apiDetection: ApiDetectionRepository(),
  );

  // ── ViewModel Setup ─────────────────────────────────────────────────────
  final authViewModel = AuthViewModel(authRepo: authRepo);
  final homeViewModel = HomeViewModel(detectionRepo: detectionRepo);
  final historyViewModel = HistoryViewModel(detectionRepo: detectionRepo);
  final profileViewModel = ProfileViewModel(userRepo: userRepo);
  final detectionViewModel = DetectionViewModel(detectionRepo: detectionRepo);
  final questionnaireViewModel =
      QuestionnaireViewModel(questionRepo: questionRepo);

  runApp(
    MultiProvider(
      providers: [
        // ── Existing Providers ──
        ChangeNotifierProvider(create: (_) => EmotionDetector()..init()),
        ChangeNotifierProvider.value(value: questionnaireViewModel..initData()),
        ChangeNotifierProvider.value(value: localeProvider),
        // ── Repository Providers (for direct access if needed) ──
        Provider<AuthRepository>.value(value: authRepo),
        Provider<DetectionRepository>.value(value: detectionRepo),
        Provider<UserRepository>.value(value: userRepo),
        Provider<QuestionRepository>.value(value: questionRepo),
        Provider<RecommendationRepository>.value(value: recommendationRepo),
        Provider<SyncService>.value(value: syncService),

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

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Aura Echo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: _router,
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
