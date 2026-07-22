import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

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

    final tabs = [
      (icon: Icons.home_rounded, label: l10n.home),
      (icon: Icons.explore_rounded, label: isId ? 'Jelajah' : 'Discover'),
      (icon: Icons.settings_rounded, label: isId ? 'Pengaturan' : 'Settings'),
    ];

    return Scaffold(
      backgroundColor: p.canvas,
      body: navigationShell,
      bottomNavigationBar: _BottomNav(
        tabs: tabs,
        currentIndex: navigationShell.currentIndex,
        onTabTapped: _onTabTapped,
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.tabs,
    required this.currentIndex,
    required this.onTabTapped,
  });

  final List<({IconData icon, String label})> tabs;
  final int currentIndex;
  final ValueChanged<int> onTabTapped;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.hairline, width: AppBorder.thin)),
        boxShadow: [
          BoxShadow(
            color: p.shadow,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.navHeight.h,
          child: Row(
            children: List.generate(tabs.length, (i) {
              return _NavItem(
                icon: tabs[i].icon,
                label: tabs[i].label,
                selected: currentIndex == i,
                onTap: () => onTabTapped(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animated pill background
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: selected ? AppSpacing.md.w : AppSpacing.sm.w,
                vertical: AppSpacing.xxs.h + 2,
              ),
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          p.strawberry,
                          Color.lerp(p.strawberry, p.primary, 0.18)!,
                        ],
                      )
                    : null,
                borderRadius: AppRadius.chip,
                border: selected
                    ? Border.all(
                        color: p.primary.withValues(alpha: 0.2),
                        width: AppBorder.thin,
                      )
                    : null,
              ),
              child: Icon(
                icon,
                color: selected ? p.primaryFocus : p.inkFaint,
                size: 22.sp,
              ),
            ),
            SizedBox(height: AppSpacing.xxs.h),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: AppTypography.navLink.copyWith(
                color: selected ? p.primaryFocus : p.inkFaint,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w400,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
