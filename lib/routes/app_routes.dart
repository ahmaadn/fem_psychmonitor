import 'package:fem_psychmonitor/pages/home_page.dart';
import 'package:fem_psychmonitor/pages/login_page.dart';
import 'package:fem_psychmonitor/pages/splash_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String onBoarding = '/onboarding';

  //  Middleware untuk authentication
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    bool isLoggedIn = false, // Simulasi status login
  }) {
    final protectedRoutes = []; //[home, profile];

    // Jika ke halaman rahasia tapi belum login -> tendang ke login
    if (protectedRoutes.contains(settings.name) && !isLoggedIn) {
      return MaterialPageRoute(builder: (_) => const LoginPage());
    }

    // Navigasi
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case onBoarding:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
