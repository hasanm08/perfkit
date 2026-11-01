import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';

// ❌ PERFORMANCE PROBLEM:
// Expensive synchronous sorting and filtering run inside build() on every
// rebuild. Derived collections are recreated from scratch each time.
//
// WHY IT IS A PROBLEM:
// build() should describe UI. Heavy CPU work on the UI isolate delays
// frame production and can cause jank when the parent rebuilds often.
//
// HOW TO FIX:
// Precompute or cache derived data when inputs change; for genuinely
// CPU-heavy work, move computation off the UI isolate.
//
// SEE FIXED IMPLEMENTATION:
// lib/features/performance_lab/examples/fixed/expensive_build_fixed.dart

class ExpensiveBuildBroken extends StatefulWidget {
  const ExpensiveBuildBroken({
    super.key,
    required this.controller,
    required this.datasetSize,
  });

  final LabDemoController controller;
  final int datasetSize;

  @override
  State<ExpensiveBuildBroken> createState() => _ExpensiveBuildBrokenState();
}

class _ExpensiveBuildBrokenState extends State<ExpensiveBuildBroken> {
  int _nudge = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  void _onController() {
    if (widget.controller.isRunning) {
      setState(() => _nudge++);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  List<_Item> _computeExpensive(int size) {
    final sw = Stopwatch()..start();
    final rng = Random(42);
    final items = List.generate(
      size,
      (i) => _Item(id: i, score: rng.nextDouble() * 1000, label: 'Item $i'),
    );
    // Intentionally expensive: repeated sorts + filter.
    for (var pass = 0; pass < 3; pass++) {
      items.sort((a, b) => b.score.compareTo(a.score));
    }
    final filtered = items.where((e) => e.score > 250).toList()
      ..sort((a, b) => a.label.compareTo(b.label));
    sw.stop();
    widget.controller.setMetric(
      MetricSnapshot(
        label: 'build() compute',
        value: '${sw.elapsedMilliseconds}',
        unit: 'ms',
        source: MetricSource.actual,
        note: 'Stopwatch around work inside build()',
      ),
    );
    widget.controller.setMetric(
      MetricSnapshot(
        label: 'Dataset size',
        value: '$size',
        source: MetricSource.counter,
      ),
    );
    return filtered.take(50).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _computeExpensive(widget.datasetSize);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PerfKitColors.broken.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PerfKitColors.broken),
            ),
            child: Text(
              'Nudge=$_nudge — sorting ${widget.datasetSize} items inside build()',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: rows.length,
              itemBuilder: (_, i) {
                final item = rows[i];
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

class _Item {
  _Item({required this.id, required this.score, required this.label});
  final int id;
  final double score;
  final String label;
}
