import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

/// Simulated network conditions for deterministic Offline Lab demos.
/// Explicitly NOT the device's real connectivity.
enum NetworkMode { online, offline, slow, serverUnavailable, intermittent }

class SimulatedNetworkException implements Exception {
  SimulatedNetworkException(this.message, {this.permanent = false});
  final String message;
  final bool permanent;
  @override
  String toString() => message;
}

class NetworkSimulator extends ChangeNotifier {
  NetworkMode _mode = NetworkMode.online;
  final List<String> requestLog = [];
  final _rng = Random(1);

  NetworkMode get mode => _mode;

  void setMode(NetworkMode mode) {
    _mode = mode;
    notifyListeners();
  }

  bool get isSimulatedConnected =>
      _mode != NetworkMode.offline && _mode != NetworkMode.serverUnavailable;

  /// Link-layer "connected" flag — intentionally naive for the broken demos.
  bool get naiveLinkConnected => _mode != NetworkMode.offline;

  Future<T> run<T>(
    String label,
    Future<T> Function() action, {
    Duration timeout = const Duration(seconds: 3),
    bool allowRetryableFailure = true,
  }) async {
    _log('→ $label [${_mode.name}]');
    switch (_mode) {
      case NetworkMode.offline:
        await Future<void>.delayed(const Duration(milliseconds: 80));
        _log('✗ $label offline');
        throw SimulatedNetworkException('No route to host (simulated offline)');
      case NetworkMode.serverUnavailable:
        await Future<void>.delayed(const Duration(milliseconds: 120));
        _log('✗ $label HTTP 503');
        throw SimulatedNetworkException(
          'Server unavailable (503)',
          permanent: false,
        );
      case NetworkMode.slow:
        await Future<void>.delayed(const Duration(milliseconds: 1800));
        break;
      case NetworkMode.intermittent:
        if (_rng.nextBool()) {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          _log('✗ $label intermittent drop');
          throw SimulatedNetworkException('Connection reset (simulated)');
        }
        await Future<void>.delayed(const Duration(milliseconds: 400));
        break;
      case NetworkMode.online:
        await Future<void>.delayed(const Duration(milliseconds: 120));
        break;
    }

    try {
      final result = await action().timeout(timeout);
      _log('✓ $label');
      return result;
    } on TimeoutException {
      _log('✗ $label timeout');
      throw SimulatedNetworkException('Request timed out');
    }
  }

  /// Broken demos may omit timeouts entirely.
  Future<T> runWithoutTimeout<T>(
    String label,
    Future<T> Function() action,
  ) async {
    _log('→ $label [no-timeout][${_mode.name}]');
    if (_mode == NetworkMode.offline) {
      // Hang forever-ish for demo — cancelled by lab reset via Completer pattern.
      await Future<void>.delayed(const Duration(days: 1));
    }
    if (_mode == NetworkMode.slow || _mode == NetworkMode.serverUnavailable) {
      await Future<void>.delayed(const Duration(days: 1));
    }
    return action();
  }

  void _log(String line) {
    final stamp = DateTime.now().toIso8601String().substring(11, 19);
    requestLog.add('[$stamp] $line');
    while (requestLog.length > 100) {
      requestLog.removeAt(0);
    }
    notifyListeners();
  }

  void clearLog() {
    requestLog.clear();
    notifyListeners();
  }
}
