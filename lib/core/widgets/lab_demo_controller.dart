import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../models/metric_snapshot.dart';

/// Shared start/stop/reset + metric bus for lab demos.
class LabDemoController extends ChangeNotifier {
  bool _running = false;
  final Map<String, MetricSnapshot> _metrics = {};
  int _generation = 0;
  bool _disposed = false;
  bool _frameNotifyScheduled = false;

  bool get isRunning => _running;
  int get generation => _generation;
  Map<String, MetricSnapshot> get metrics => Map.unmodifiable(_metrics);

  void start() {
    if (_running) return;
    _running = true;
    _notify();
  }

  void stop() {
    if (!_running) return;
    _running = false;
    _notify();
  }

  void reset() {
    _running = false;
    _metrics.clear();
    _generation++;
    _notify();
  }

  void setMetric(MetricSnapshot metric) {
    _metrics[metric.label] = metric;
    _notify();
  }

  void setMetrics(Iterable<MetricSnapshot> metrics) {
    for (final m in metrics) {
      _metrics[m.label] = m;
    }
    _notify();
  }

  void clearMetrics() {
    _metrics.clear();
    _notify();
  }

  /// Ancestor [ListenableBuilder]s listen to this controller. Notifying them
  /// while a demo is still building marks those ancestors dirty and throws
  /// "setState() or markNeedsBuild() called during build."
  void _notify() {
    if (_disposed) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    final duringBuild =
        phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks;
    if (!duringBuild) {
      notifyListeners();
      return;
    }
    if (_frameNotifyScheduled) return;
    _frameNotifyScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _frameNotifyScheduled = false;
      if (_disposed) return;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
