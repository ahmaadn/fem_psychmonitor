import 'dart:ui';

import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/data/repositories/dummy/dummy_auth_repository.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    final authVm = AuthViewModel(authRepo: DummyAuthRepository());
    final localeProvider = LocaleProvider();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authVm),
          ChangeNotifierProvider.value(value: localeProvider),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    expect(find.text('FemMonitor'), findsOneWidget);
  });
}
