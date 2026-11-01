import 'package:flutter_test/flutter_test.dart';
import 'package:perfkit/core/diagnostics/rebuild_counter.dart';

void main() {
  test('RebuildCounter increments and resets', () {
    final c = RebuildCounter();
    c.increment('a');
    c.increment('a');
    c.increment('b');
    expect(c.countFor('a'), 2);
    expect(c.countFor('b'), 1);
    c.reset();
    expect(c.countFor('a'), 0);
  });
}
