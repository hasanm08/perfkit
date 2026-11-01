import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/diagnostics/lifecycle_counters.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';
import '../broken/object_lifecycle_broken.dart' show Uint8Blob;

// ✅ OPTIMIZATION:
// Capture only a small primitive (or nothing). Clear lingering callbacks
// when finished. Large graphs are not retained by permanent roots.
//
// WHY IT WORKS:
// Narrow captures + cancelled registrations restore reachability.
//
// PRODUCTION NOTE:
// Prefer tear-offs / method refs carefully — they can capture `this`.

class ClosureRetainFixed extends StatefulWidget {
  const ClosureRetainFixed({super.key, required this.controller});
  final LabDemoController controller;

  @override
  State<ClosureRetainFixed> createState() => _ClosureRetainFixedState();
}

class _ClosureRetainFixedState extends State<ClosureRetainFixed> {
  final List<void Function()> _local = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  void _onController() {
    if (!widget.controller.isRunning) return;
    final graph = List.generate(40, (i) => Uint8Blob(i));
    final count = graph.length; // capture primitive only
    _local.add(() {
      assert(count == 40);
    });
    // Release graph + callbacks.
    _local.clear();
    lifecycleCounters.setRetainedObjects(0);
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Lingering closures',
        value: '${_local.length}',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'Captured',
        value: 'int count only',
        source: MetricSource.counter,
      ),
    ]);
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _local.clear();
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
            color: PerfKitColors.fixed.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PerfKitColors.fixed),
          ),
          child: const Text(
            'Callbacks capture a primitive and are cleared after use',
            style: TextStyle(fontSize: 12),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'No permanent closure root retains the graph',
              style: TextStyle(color: PerfKitColors.secondaryText),
            ),
          ),
        ),
      ],
    );
  }
}
