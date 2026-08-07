import 'dart:math' as math;
import 'dart:ui';

import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_emoji.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_radar_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// The radar axis labels are positioned with hand-computed geometry that
/// mirrors `RadarChartPainter`, so these tests pin the parts that would break
/// silently: one label per emotion, drawn outside the plot, inside the widget.
void main() {
  Widget host(Widget child) => ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) =>
        MaterialApp(home: Scaffold(body: Center(child: child))),
  );

  setUp(() {
    // Keep the raster emoji from hitting the asset bundle during layout.
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('renders one emoji + name per emotion axis', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      host(
        SizedBox(
          width: 358,
          child: EmotionRadarChart(
            values: const [0.1, 0.2, 0.3, 0.2, 0.1, 0.1],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byType(EmotionEmoji),
      findsNWidgets(EmotionLabelType.values.length),
    );
    for (final e in EmotionLabelType.values) {
      expect(find.text(e.displayName), findsOneWidget);
    }
  });

  testWidgets('axis labels sit outside the ring and stay in bounds', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      host(
        SizedBox(
          width: 358,
          child: EmotionRadarChart(
            values: const [0.5, 0.5, 0.5, 0.5, 0.5, 0.5],
          ),
        ),
      ),
    );
    await tester.pump();

    final chartRect = tester.getRect(find.byType(EmotionRadarChart));
    // Measure against the plot box (the sized chart area), not the whole
    // widget, whose height also covers the title row.
    final plotRect = tester.getRect(find.byType(RadarChart));
    final center = plotRect.center;

    for (final e in EmotionLabelType.values) {
      final labelRect = tester.getRect(find.text(e.displayName));
      expect(
        chartRect.contains(labelRect.center),
        isTrue,
        reason: '${e.displayName} label escaped the chart box',
      );
      // Outside the plotted ring, so a label never covers the data shape.
      final d = (labelRect.center - center).distance;
      expect(
        d,
        greaterThan(plotRect.shortestSide * 0.25),
        reason: '${e.displayName} label sits on top of the plot',
      );
    }

    // Labels must ring the center rather than collapse onto one point.
    final angles = EmotionLabelType.values.map((e) {
      final c = tester.getRect(find.text(e.displayName)).center;
      return math.atan2(c.dy - center.dy, c.dx - center.dx);
    }).toSet();
    expect(angles.length, EmotionLabelType.values.length);
  });
}
