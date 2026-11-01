import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/diagnostics/lifecycle_counters.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';

// ❌ MEMORY PROBLEM:
// A long-lived singleton retains large demo objects forever, even after
// the UI that needed them is gone.
//
// WHY IT IS A PROBLEM:
// Reachability from a permanent root (singleton) prevents GC. Objects
// outlive their intended scope.
//
// HOW TO FIX:
// Define clear ownership scopes; release references when done.
//
// SEE FIXED IMPLEMENTATION:
// lib/features/memory_lab/examples/fixed/object_lifecycle_fixed.dart

class LeakyObjectRegistry {
  LeakyObjectRegistry._();
  static final instance = LeakyObjectRegistry._();
  final List<Uint8Blob> retained = [];
}

class Uint8Blob {
  Uint8Blob(this.id) : bytes = List<int>.filled(64 * 1024, id % 256);
  final int id;
  final List<int> bytes;
}

class ObjectLifecycleBroken extends StatefulWidget {
  const ObjectLifecycleBroken({super.key, required this.controller});
  final LabDemoController controller;

  @override
  State<ObjectLifecycleBroken> createState() => _ObjectLifecycleBrokenState();
}

class _ObjectLifecycleBrokenState extends State<ObjectLifecycleBroken> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  void _onController() {
    if (!widget.controller.isRunning) return;
    for (var i = 0; i < 10; i++) {
      LeakyObjectRegistry.instance.retained.add(
        Uint8Blob(LeakyObjectRegistry.instance.retained.length),
      );
    }
    lifecycleCounters.setRetainedObjects(
      LeakyObjectRegistry.instance.retained.length,
    );
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Retained blobs',
        value: '${LeakyObjectRegistry.instance.retained.length}',
        source: MetricSource.counter,
        note: 'Held by singleton registry',
      ),
      MetricSnapshot(
        label: 'Approx bytes',
        value:
            '${LeakyObjectRegistry.instance.retained.length * 64} KB (payload)',
        source: MetricSource.counter,
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
    final n = LeakyObjectRegistry.instance.retained.length;
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
            'Singleton retains $n blobs (~64KB each). Switching scenarios '
            'does not clear them.',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Objects remain reachable from LeakyObjectRegistry',
              style: TextStyle(color: PerfKitColors.secondaryText),
            ),
          ),
        ),
      ],
    );
  }
}
