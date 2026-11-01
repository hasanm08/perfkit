import 'package:flutter_test/flutter_test.dart';
import 'package:perfkit/features/testing_lab/examples/fixed/deterministic_helpers.dart';

void main() {
  test('greeting uses injected clock', () {
    expect(greet(FixedClock(DateTime(2026, 1, 1, 9))), 'Good morning');
    expect(greet(FixedClock(DateTime(2026, 1, 1, 15))), 'Good afternoon');
  });
}
