import 'dart:math';

import 'network_simulator.dart';

class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 200),
    this.timeout = const Duration(seconds: 3),
  });

  final int maxAttempts;
  final Duration baseDelay;
  final Duration timeout;

  /// Fixed: bounded retries with exponential backoff + jitter.
  /// Skips retries for permanent errors.
  Future<T> execute<T>(
    NetworkSimulator net,
    String label,
    Future<T> Function() action,
  ) async {
    final rng = Random();
    Object? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await net.run(label, action, timeout: timeout);
      } on SimulatedNetworkException catch (e) {
        lastError = e;
        if (e.permanent || attempt == maxAttempts) rethrow;
        final backoff = baseDelay * (1 << (attempt - 1));
        final jitter = Duration(milliseconds: rng.nextInt(100));
        await Future<void>.delayed(backoff + jitter);
      }
    }
    throw lastError ?? StateError('retry failed');
  }
}

/// Broken: retries every error immediately with no bound/timeout awareness.
class NaiveRetry {
  Future<T> execute<T>(
    NetworkSimulator net,
    String label,
    Future<T> Function() action,
  ) async {
    // No timeout, immediate retry loop — intentionally bad.
    while (true) {
      try {
        return await net.runWithoutTimeout(label, action);
      } catch (_) {
        await Future<void>.delayed(Duration.zero);
      }
    }
  }
}
