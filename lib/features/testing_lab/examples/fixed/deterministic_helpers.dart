// ✅ OPTIMIZATION:
// Injected clock and isolated fixtures make tests deterministic.
//
// WHY IT WORKS:
// Tests control time and shared state instead of depending on the environment.
//
// PRODUCTION NOTE:
// Prefer fakes over mocks when behavior is simple and stable.

abstract class Clock {
  DateTime now();
}

class FixedClock implements Clock {
  FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

String greet(Clock clock) {
  final hour = clock.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 18) return 'Good afternoon';
  return 'Good evening';
}

class PathPlatform {
  PathPlatform(this.pathSeparator);
  final String pathSeparator;
}

class CounterFixture {
  int count = 0;
}
