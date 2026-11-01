import 'package:flutter_test/flutter_test.dart';
import 'package:perfkit/features/testing_lab/examples/fixed/deterministic_helpers.dart';

void main() {
  late CounterFixture fixture;

  setUp(() => fixture = CounterFixture());

  test('starts at zero', () {
    expect(fixture.count, 0);
  });

  test('increment is isolated', () {
    fixture.count++;
    expect(fixture.count, 1);
  });

  test('still starts at zero thanks to setUp', () {
    expect(fixture.count, 0);
  });
}
