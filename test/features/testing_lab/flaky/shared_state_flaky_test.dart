import 'package:flutter_test/flutter_test.dart';
import 'package:perfkit/features/testing_lab/examples/broken/flaky_helpers.dart';

void main() {
  test('mutates global', () {
    sharedGlobalCounter++;
    expect(sharedGlobalCounter, greaterThan(0));
  }, skip: true);

  test('expects global zero (order-dependent)', () {
    // ❌ Depends on previous test not having run / order.
    expect(sharedGlobalCounter, 0);
  }, skip: true);
}
