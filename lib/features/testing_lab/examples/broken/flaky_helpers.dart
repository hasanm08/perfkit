// ❌ TESTING PROBLEM:
// Helpers that encode flaky patterns — used only by isolated flaky tests.
//
// WHY IT IS A PROBLEM:
// Arbitrary delays, wall clocks, Platform reads, and shared globals make CI brittle.
//
// HOW TO FIX:
// See lib/features/testing_lab/examples/fixed/deterministic_helpers.dart
//
// SEE FIXED IMPLEMENTATION:
// lib/features/testing_lab/examples/fixed/deterministic_helpers.dart

int sharedGlobalCounter = 0;

String greetWallClock() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 18) return 'Good afternoon';
  return 'Good evening';
}
