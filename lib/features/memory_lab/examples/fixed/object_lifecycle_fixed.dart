import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/diagnostics/lifecycle_counters.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';
import '../broken/object_lifecycle_broken.dart' show Uint8Blob;

// ✅ OPTIMIZATION:
// Blobs are owned by the screen scope and released when work completes.
//
// WHY IT WORKS:
// No permanent root retains the objects; GC can reclaim them.
//
// PRODUCTION NOTE:
// Prefer constructor injection over ambient singletons for session data.

class ObjectLifecycleFixed extends StatefulWidget {
  const ObjectLifecycleFixed({super.key, required this.controller});
  final LabDemoController controller;

  @override
  State<ObjectLifecycleFixed> createState() => _ObjectLifecycleFixedState();
}

class _ObjectLifecycleFixedState extends State<ObjectLifecycleFixed> {
  final List<Uint8Blob> _scoped = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  void _onController() {
    if (!widget.controller.isRunning) return;
    _scoped
      ..clear()
      ..addAll(List.generate(10, (i) => Uint8Blob(i)));
    // Release when "done".
    final count = _scoped.length;
    _scoped.clear();
    lifecycleCounters.setRetainedObjects(0);
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Created then released',
        value: '$count',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'Retained now',
        value: '${_scoped.length}',
        source: MetricSource.counter,
      ),
    ]);
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _scoped.clear();
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
            'Scoped ownership: create → use → clear references',
            style: TextStyle(fontSize: 12),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'No singleton retention',
              style: TextStyle(color: PerfKitColors.secondaryText),
            ),
          ),
        ),
      ],
    );
  }
}
