import 'package:flutter_test/flutter_test.dart';
import 'package:perfkit/features/testing_lab/examples/broken/flaky_helpers.dart';

void main() {
  test('wall-clock greeting is environment dependent', () {
    //! Main issue: wall-clock dependency makes the assertion environment-tied.
    final text = greetWallClock();
    expect(text.contains('Good'), isTrue);
  }, skip: true);
}
