import 'package:flutter_test/flutter_test.dart';

/// Intentionally timing-sensitive. Excluded from default CI.
/// Documented nondeterminism: microtask may not complete within 1ms under load.
void main() {
  test('flaky async timing (documented)', () async {
    var done = false;
    Future.microtask(() => done = true);
    // ❌ Arbitrary delay — may flake under CI load.
    await Future<void>.delayed(const Duration(milliseconds: 1));
    expect(done, isTrue);
  }, skip: true);
}
