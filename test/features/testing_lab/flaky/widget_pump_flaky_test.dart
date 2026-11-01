import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pumpAndSettle with infinite animation', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: _ForeverSpinner())),
    );
    // ❌ pumpAndSettle never completes with repeating animation.
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }, skip: true);
}

class _ForeverSpinner extends StatefulWidget {
  const _ForeverSpinner();
  @override
  State<_ForeverSpinner> createState() => _ForeverSpinnerState();
}

class _ForeverSpinnerState extends State<_ForeverSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const CircularProgressIndicator();
}
