import 'package:flutter_test/flutter_test.dart';
import 'package:perfkit/features/testing_lab/examples/broken/flaky_helpers.dart';

void main() {
  test('wall-clock greeting is environment dependent', () {
    // ❌ Depends on DateTime.now(); assertion is weak/non-deterministic by hour.
    final text = greetWallClock();
    expect(text.contains('Good'), isTrue);
  }, skip: true);
}
