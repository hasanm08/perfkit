import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('explicit pump finds ready label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Ready'))),
    );
    await tester.pump();
    expect(find.text('Ready'), findsOneWidget);
  });
}
