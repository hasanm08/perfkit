import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfkit/app/app.dart';
import 'package:perfkit/core/progress/module_progress_store.dart';

void main() {
  testWidgets('fixed labs do not markNeedsBuild during build', (tester) async {
    tester.view.physicalSize = const Size(1800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(PerfKitApp(progress: ModuleProgressStore()));
    await tester.pump();

    Future<void> openLab(String label) async {
      await tester.tap(find.text(label).first);
      await tester.pump();
      await tester.pump();
      _expectNoBuildPhaseError(tester);
    }

    await openLab('Performance');
    expect(find.text('FIXED IMPLEMENTATION'), findsOneWidget);

    for (final title in [
      '2. Expensive Build Methods',
      '3. Poor List Rendering',
      '4. Excessive Image Decoding',
      '5. Expensive Layout and Painting',
      '1. Unnecessary Widget Rebuilds',
    ]) {
      await tester.tap(find.text(title));
      await tester.pump();
      await tester.pump();
      _expectNoBuildPhaseError(tester);
    }

    await openLab('Memory');
    await openLab('Offline');
    expect(find.textContaining('Fixed:'), findsWidgets);
    await openLab('Deep Links');
    await openLab('Testing');
  });
}

void _expectNoBuildPhaseError(WidgetTester tester) {
  Object? exception;
  while ((exception = tester.takeException()) != null) {
    expect(
      exception.toString(),
      isNot(contains('setState() or markNeedsBuild() called during build')),
      reason: '$exception',
    );
  }
}
