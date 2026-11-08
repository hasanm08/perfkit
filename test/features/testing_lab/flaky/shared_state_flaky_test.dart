import 'package:flutter_test/flutter_test.dart';
import 'package:perfkit/features/testing_lab/examples/broken/flaky_helpers.dart';

void main() {
  test('mutates global', () {
    //! Main issue: mutates shared global with no reset between tests.
    sharedGlobalCounter++;
    expect(sharedGlobalCounter, greaterThan(0));
  }, skip: true);

  test('expects global zero (order-dependent)', () {
    //! Main issue: assertion depends on test order / leftover global state.
    expect(sharedGlobalCounter, 0);
  }, skip: true);
}
