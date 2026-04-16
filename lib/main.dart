import 'package:flutter/material.dart';
import 'app/config/app_theme.dart';
import 'routes/app_routes.dart';

// Variabel Global sederhana untuk status login (Tanpa Provider)
ValueNotifier<bool> authNotifier = ValueNotifier<bool>(false);

void main() {
  runApp(const PsychMonitorApp());
}

class PsychMonitorApp extends StatelessWidget {
  const PsychMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: authNotifier,
      builder: (context, isLoggedIn, child) {
        return MaterialApp(
          title: 'Psych Monitor',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,

          // Guard dipasang di sini
          onGenerateRoute: (settings) =>
              AppRoutes.onGenerateRoute(settings, isLoggedIn: false),

          // Halaman awal
          initialRoute: AppRoutes.splash,
        );
      },
    );
  }
}
