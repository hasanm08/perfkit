import 'package:flutter_test/flutter_test.dart';
import 'package:perfkit/app/app.dart';
import 'package:perfkit/core/progress/module_progress_store.dart';

void main() {
  testWidgets('PerfKit loads overview', (tester) async {
    final progress = ModuleProgressStore();
    await tester.pumpWidget(PerfKitApp(progress: progress));
    await tester.pumpAndSettle();
    expect(find.text('PerfKit'), findsWidgets);
    expect(find.textContaining('Measure. Diagnose. Optimize.'), findsWidgets);
  });
}
