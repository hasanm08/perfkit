import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/diagnostics/lifecycle_counters.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';

// ✅ OPTIMIZATION:
// Timers are cancelled when the simulated screen closes and in dispose.
//
// WHY IT WORKS:
// No lingering callbacks keep the host reachable.
//
// PRODUCTION NOTE:
// Also remove ScrollController/Animation listeners symmetrically.

class SurvivingTimersFixed extends StatefulWidget {
  const SurvivingTimersFixed({super.key, required this.controller});
  final LabDemoController controller;

  @override
  State<SurvivingTimersFixed> createState() => _SurvivingTimersFixedState();
}

class _SurvivingTimersFixedState extends State<SurvivingTimersFixed> {
  int _cycles = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  void _onController() {
    if (!widget.controller.isRunning) return;
    final timer = Timer.periodic(const Duration(milliseconds: 200), (_) {});
    lifecycleCounters.recordTimerCreated();
    timer.cancel();
    lifecycleCounters.recordTimerCancelled();
    _cycles++;
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Active timers',
        value: '${lifecycleCounters.activeTimers}',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'Clean cycles',
        value: '$_cycles',
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
          child: Text(
            '$_cycles open/close cycles with timer.cancel() on close',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Active timer count should remain ~0',
              style: TextStyle(color: PerfKitColors.secondaryText),
            ),
          ),
        ),
      ],
    );
  }
}
