import 'package:flutter_test/flutter_test.dart';
import 'package:perfkit/features/testing_lab/examples/fixed/deterministic_helpers.dart';

void main() {
  test('path separator via injected platform', () {
    expect(PathPlatform('/').pathSeparator, '/');
    expect(PathPlatform(r'\').pathSeparator, r'\');
  });
}
