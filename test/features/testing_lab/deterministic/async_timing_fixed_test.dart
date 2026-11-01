import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deterministic async awaits completer', () async {
    final done = Completer<void>();
    Future.microtask(done.complete);
    await done.future;
    expect(done.isCompleted, isTrue);
  });
}
