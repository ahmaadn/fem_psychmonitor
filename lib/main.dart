import 'package:fem_psychmonitor/app/config/app_theme.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmotionDetector()..init()),
        ChangeNotifierProvider(create: (_) => QuestionnaireViewModel()..initData()),
        ChangeNotifierProvider.value(value: localeProvider),
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
