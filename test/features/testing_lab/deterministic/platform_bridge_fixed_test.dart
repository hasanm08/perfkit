import 'package:flutter_test/flutter_test.dart';
import 'package:perfkit/features/testing_lab/examples/fixed/deterministic_helpers.dart';

void main() {
  test('path separator via injected platform', () {
    //? Main fix: inject platform bridge; do not read dart:io in unit tests.
    expect(PathPlatform('/').pathSeparator, '/');
    expect(PathPlatform(r'\').pathSeparator, r'\');
  });
}
