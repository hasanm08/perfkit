import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/diagnostics/lifecycle_counters.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';
import 'object_lifecycle_broken.dart' show Uint8Blob;

// ❌ MEMORY PROBLEM:
// A long-lived callback closes over a large object graph. Even after the
// UI drops its field reference, the closure keeps the graph reachable.
//
// WHY IT IS A PROBLEM:
// Closures capture variables. Capturing `this` or a large model from a
// permanent listener/timer retains more than intended.
//
// HOW TO FIX:
// Capture only what you need, cancel listeners, null out large fields,
// and understand reachability from permanent roots.
//
// SEE FIXED IMPLEMENTATION:
// lib/features/memory_lab/examples/fixed/closure_retain_fixed.dart

class ClosureRetainBroken extends StatefulWidget {
  const ClosureRetainBroken({super.key, required this.controller});
  final LabDemoController controller;

  @override
  State<ClosureRetainBroken> createState() => _ClosureRetainBrokenState();
}

/// Public root used by the Memory Lab cleanup action.
final List<void Function()> closureRetainLingering = [];

class _ClosureRetainBrokenState extends State<ClosureRetainBroken> {
  List<Uint8Blob>? _graph;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  void _onController() {
    if (!widget.controller.isRunning) return;
    _graph = List.generate(40, (i) => Uint8Blob(i));
    // Closure captures `_graph` (and effectively this State pattern).
    closureRetainLingering.add(() {
      final n = _graph?.length ?? 0;
      // Touch the graph so the capture is "used".
      if (n > 0) {
        assert(_graph!.first.bytes.isNotEmpty);
      }
    });
    // Drop the field — but the closure still retains the list.
    _graph = null;
    lifecycleCounters.setRetainedObjects(closureRetainLingering.length * 40);
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Lingering closures',
        value: '${closureRetainLingering.length}',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'Field after null',
        value: '${_graph == null}',
        source: MetricSource.counter,
        note: 'Field is null; closures still retain graphs',
      ),
    ]);
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: PerfKitColors.broken.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PerfKitColors.broken),
          ),
          child: Text(
            '${closureRetainLingering.length} static closures '
            'retain large graphs after field nulling',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Reachability ≠ field nullity',
              style: TextStyle(color: PerfKitColors.secondaryText),
            ),
          ),
        ),
      ],
    );
  }
}
