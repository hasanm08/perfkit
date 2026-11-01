import 'dart:collection';

import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';

/// Collects [FrameTiming] samples from the engine when available.
///
/// Values in debug mode are NOT representative of release/profile performance.
class FrameTimingMonitor extends ChangeNotifier {
  FrameTimingMonitor({this.maxSamples = 120});

  final int maxSamples;
  final Queue<FrameTiming> _samples = Queue<FrameTiming>();
  bool _listening = false;

  bool get isListening => _listening;
  int get sampleCount => _samples.length;

  void start() {
    if (_listening) return;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    _listening = true;
    notifyListeners();
  }

  void stop() {
    if (!_listening) return;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    _listening = false;
    notifyListeners();
  }

  void clear() {
    _samples.clear();
    notifyListeners();
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      _samples.addLast(t);
      while (_samples.length > maxSamples) {
        _samples.removeFirst();
      }
    }
    notifyListeners();
  }

  /// Average build duration in microseconds, or null if no samples.
  double? get averageBuildMicros {
    if (_samples.isEmpty) return null;
    final total = _samples.fold<int>(
      0,
      (sum, t) => sum + t.buildDuration.inMicroseconds,
    );
    return total / _samples.length;
  }

  /// Average raster duration in microseconds, or null if no samples.
  double? get averageRasterMicros {
    if (_samples.isEmpty) return null;
    final total = _samples.fold<int>(
      0,
      (sum, t) => sum + t.rasterDuration.inMicroseconds,
    );
    return total / _samples.length;
  }

  FrameTiming? get lastSample => _samples.isEmpty ? null : _samples.last;

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
