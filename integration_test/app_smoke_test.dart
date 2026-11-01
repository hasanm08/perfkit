import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:perfkit/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shell shows overview and can open Performance Lab', (
    tester,
  ) async {
    await tester.pumpWidget(const PerfKitApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('Performance Lab'), findsOneWidget);
    await tester.tap(find.textContaining('Performance Lab'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Performance Lab'), findsWidgets);
  });
}
