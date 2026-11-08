// ✅ OPTIMIZATION:
// Injected clock and isolated fixtures make tests deterministic.
//
// WHY IT WORKS:
// Tests control time and shared state instead of depending on the environment.
//
// PRODUCTION NOTE:
// Prefer fakes over mocks when behavior is simple and stable.

//? Main fix: inject a Clock so tests control time.
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
  //? Main fix: read time from injected clock, not DateTime.now().
  final hour = clock.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 18) return 'Good afternoon';
  return 'Good evening';
}

//? Main fix: abstract platform deps instead of reading dart:io directly.
class PathPlatform {
  PathPlatform(this.pathSeparator);
  final String pathSeparator;
}

//? Main fix: per-test fixture instead of a shared global counter.
class CounterFixture {
  int count = 0;
}
