import 'package:fem_psychmonitor/app/utils/use_page_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

class NavigatorContainerWithPageView extends HookWidget {
  const NavigatorContainerWithPageView({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final (:pageController, :onPageChanged) = usePageView(navigationShell);

    return PageView(
      controller: pageController,
      physics: const ClampingScrollPhysics(),
      onPageChanged: onPageChanged,
      children: children,
    );
  }
}
