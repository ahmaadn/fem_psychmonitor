import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  void _onTabTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final isId = Localizations.localeOf(context).languageCode == 'id';

    final items = [
      AppBottomNavItem(icon: Icons.home_rounded, label: l10n.home),
      AppBottomNavItem(
        icon: Icons.explore_rounded,
        label: isId ? 'Jelajah' : 'Discover',
      ),
      AppBottomNavItem(
        icon: Icons.settings_rounded,
        label: isId ? 'Pengaturan' : 'Settings',
      ),
    ];

    return Scaffold(
      backgroundColor: p.canvas,
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        items: items,
        currentIndex: navigationShell.currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
