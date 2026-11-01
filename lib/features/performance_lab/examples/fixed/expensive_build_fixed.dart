import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';

// ✅ OPTIMIZATION:
// Derived data is computed when inputs change (or via compute/isolate for
// larger workloads), then build() only renders the cached result.
//
// WHY IT WORKS:
// build() stays cheap. Expensive work runs once per input change, not on
// every incidental rebuild.
//
// PRODUCTION NOTE:
// Isolates have marshalling cost — use them when the workload justifies it.

class ExpensiveBuildFixed extends StatefulWidget {
  const ExpensiveBuildFixed({
    super.key,
    required this.controller,
    required this.datasetSize,
  });

  final LabDemoController controller;
  final int datasetSize;

  @override
  State<ExpensiveBuildFixed> createState() => _ExpensiveBuildFixedState();
}

class _ExpensiveBuildFixedState extends State<ExpensiveBuildFixed> {
  List<_Item> _rows = const [];
  bool _busy = false;
  int _nudge = 0;

  bool _recomputeScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    // initState runs while the parent is building. Defer so setState and
    // metric updates do not mark ancestors dirty mid-frame.
    _scheduleRecompute();
  }

  @override
  void didUpdateWidget(covariant ExpensiveBuildFixed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.datasetSize != widget.datasetSize) {
      _scheduleRecompute();
    }
  }

  void _scheduleRecompute() {
    if (_recomputeScheduled) return;
    _recomputeScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recomputeScheduled = false;
      if (!mounted) return;
      _recompute();
    });
  }

  void _onController() {
    if (widget.controller.isRunning) {
      setState(() => _nudge++);
      _recompute();
    }
  }

  Future<void> _recompute() async {
    setState(() => _busy = true);
    final sw = Stopwatch()..start();
    final size = widget.datasetSize;
    final result = size > 8000
        ? await compute(_heavyCompute, size)
        : _heavyCompute(size);
    sw.stop();
    if (!mounted) return;
    setState(() {
      _rows = result;
      _busy = false;
    });
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Precompute',
        value: '${sw.elapsedMilliseconds}',
        unit: 'ms',
        source: MetricSource.actual,
        note: size > 8000 ? 'Via compute()/isolate' : 'Cached on input change',
      ),
      MetricSnapshot(
        label: 'Dataset size',
        value: '$size',
        source: MetricSource.counter,
      ),
    ]);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PerfKitColors.fixed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PerfKitColors.fixed),
            ),
            child: Text(
              'Nudge=$_nudge — build() renders cached rows'
              '${_busy ? ' (computing…)' : ''}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _rows.length,
              itemBuilder: (_, i) {
                final item = _rows[i];
                return ListTile(
                  dense: true,
                  title: Text(item.label),
                  trailing: Text(item.score.toStringAsFixed(1)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

List<_Item> _heavyCompute(int size) {
  final rng = Random(42);
  final items = List.generate(
    size,
    (i) => _Item(id: i, score: rng.nextDouble() * 1000, label: 'Item $i'),
  );
  for (var pass = 0; pass < 3; pass++) {
    items.sort((a, b) => b.score.compareTo(a.score));
  }
  final filtered = items.where((e) => e.score > 250).toList()
    ..sort((a, b) => a.label.compareTo(b.label));
  return filtered.take(50).toList();
}

class _Item {
  _Item({required this.id, required this.score, required this.label});
  final int id;
  final double score;
  final String label;
}
