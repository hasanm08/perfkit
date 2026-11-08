import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assumes unix path separator', () {
    //! Main issue: assumes Unix path separator — fails on Windows.
    expect(Platform.pathSeparator, '/');
  }, skip: true);
}
