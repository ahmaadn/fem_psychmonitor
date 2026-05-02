import 'package:fem_psychmonitor/app/config/app_theme.dart';
import 'package:fem_psychmonitor/detection/services/emotion_detector.dart';
import 'package:fem_psychmonitor/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => EmotionDetector()..init(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Delegate standar Material, Cupertino, dan Widget dari Flutter
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,

            // Nanti tambahkan AppLocalizations.delegate di sini jika Anda menggunakan
            // flutter_gen (l10n.yaml) untuk menerjemahkan teks custom.
          ],
          supportedLocales: const [
            Locale('en', 'US'), // English (United States)
            Locale('id', 'ID'), // Bahasa Indonesia
          ],

          builder: (context, widget) {
            // Anda dapat menambahkan pembungkus tambahan di sini jika butuh
            // (misal: bot_toast, easy_loading, dsb).
            return MediaQuery(
              // Mencegah teks membesar secara tidak wajar jika user mengubah setelan HP
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
