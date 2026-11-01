/// Distinguishes real device measurements from educational counters/simulations.
enum MetricSource {
  /// Obtained from Flutter/Dart runtime APIs (e.g. FrameTiming, ProcessInfo).
  actual,

  /// App-instrumented educational counter (rebuild counts, dispose counts).
  counter,

  /// Intentionally simulated condition (network mode, fake latency).
  simulated,
}

class MetricSnapshot {
  const MetricSnapshot({
    required this.label,
    required this.value,
    required this.source,
    this.unit = '',
    this.note,
  });

  final String label;
  final String value;
  final MetricSource source;
  final String unit;
  final String? note;

  String get sourceLabel => switch (source) {
    MetricSource.actual => 'Actual',
    MetricSource.counter => 'Counter',
    MetricSource.simulated => 'Simulated',
  };
}
