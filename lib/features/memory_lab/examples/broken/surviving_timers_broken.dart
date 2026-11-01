import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/diagnostics/lifecycle_counters.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';

// ❌ MEMORY PROBLEM:
// Periodic timers and listeners are started when a screen opens and keep
// running after the screen is removed.
//
// WHY IT IS A PROBLEM:
// Timers retain their callbacks (and thus the State/objects they capture),
// preventing GC and continuing background work.
//
// HOW TO FIX:
// Cancel timers and remove listeners in dispose / when the screen pops.
//
// SEE FIXED IMPLEMENTATION:
// lib/features/memory_lab/examples/fixed/surviving_timers_fixed.dart

class SurvivingTimersBroken extends StatefulWidget {
  const SurvivingTimersBroken({super.key, required this.controller});
  final LabDemoController controller;

  @override
  State<SurvivingTimersBroken> createState() => _SurvivingTimersBrokenState();
}

class _SurvivingTimersBrokenState extends State<SurvivingTimersBroken> {
  final List<Timer> _orphans = [];
  int _opens = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  void _onController() {
    if (!widget.controller.isRunning) return;
    // Simulate open screen → start timer → pop without cancel.
    final timer = Timer.periodic(const Duration(milliseconds: 200), (_) {});
    lifecycleCounters.recordTimerCreated();
    _orphans.add(timer);
    _opens++;
    _publish();
    setState(() {});
  }

  void _publish() {
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Active timers',
        value: '${lifecycleCounters.activeTimers}',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'Simulated opens',
        value: '$_opens',
        source: MetricSource.counter,
      ),
    ]);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    // Intentionally leave orphan timers running.
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
            '$_opens screens "closed" without cancelling timers '
            '(${_orphans.length} still scheduled)',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Press Start to leak more timers',
              style: TextStyle(color: PerfKitColors.secondaryText),
            ),
          ),
        ),
      ],
    );
  }
}
