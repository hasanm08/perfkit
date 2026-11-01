import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/diagnostics/lifecycle_counters.dart';
import '../../../../core/diagnostics/memory_probe.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';

// ✅ OPTIMIZATION:
// Controllers are disposed and subscriptions cancelled when the host
// is released. Active counters return toward zero after cleanup.
//
// WHY IT WORKS:
// Ownership is clear: the State (or host) that creates resources also
// tears them down.
//
// PRODUCTION NOTE:
// Prefer owning resources in the State that needs them; avoid globals.

class UndisposedControllersFixed extends StatefulWidget {
  const UndisposedControllersFixed({super.key, required this.controller});
  final LabDemoController controller;

  @override
  State<UndisposedControllersFixed> createState() =>
      _UndisposedControllersFixedState();
}

class _UndisposedControllersFixedState
    extends State<UndisposedControllersFixed> {
  final List<_SafeHost> _hosts = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  void _onController() {
    if (!widget.controller.isRunning) return;
    for (var i = 0; i < 5; i++) {
      final host = _SafeHost()..start();
      _hosts.add(host);
      host.dispose(); // Proper close.
      _hosts.remove(host);
    }
    _publish();
    setState(() {});
  }

  void _publish() {
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Active controllers',
        value: '${lifecycleCounters.activeControllers}',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'Active subscriptions',
        value: '${lifecycleCounters.activeSubscriptions}',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'Process RSS',
        value: MemoryProbe.formatRss(),
        source: MetricSource.actual,
      ),
    ]);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    for (final h in _hosts) {
      h.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: PerfKitColors.fixed.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PerfKitColors.fixed),
          ),
          child: const Text(
            'Hosts are disposed immediately after use. Active counts stay near 0.',
            style: TextStyle(fontSize: 12),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Create → use → dispose cycle complete',
              style: TextStyle(color: PerfKitColors.secondaryText),
            ),
          ),
        ),
      ],
    );
  }
}

class _SafeHost {
  late final TextEditingController text;
  late final StreamController<String> stream;
  StreamSubscription<String>? sub;

  void start() {
    text = TextEditingController(text: 'ok');
    lifecycleCounters.recordControllerCreated();
    stream = StreamController.broadcast();
    sub = stream.stream.listen((_) {});
    lifecycleCounters.recordSubscriptionCreated();
    stream.add('ok');
  }

  void dispose() {
    sub?.cancel();
    lifecycleCounters.recordSubscriptionCancelled();
    stream.close();
    text.dispose();
    lifecycleCounters.recordControllerDisposed();
  }
}
