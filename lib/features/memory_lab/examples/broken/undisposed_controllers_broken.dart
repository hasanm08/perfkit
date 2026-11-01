import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/diagnostics/lifecycle_counters.dart';
import '../../../../core/diagnostics/memory_probe.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';

// ❌ MEMORY PROBLEM:
// TextEditingController and StreamSubscription are created when the demo
// screen opens but never disposed/cancelled when it closes.
//
// WHY IT IS A PROBLEM:
// Listeners keep objects reachable. Repeating open/close grows retained
// controllers and subscriptions — a classic leak pattern.
//
// HOW TO FIX:
// Dispose controllers and cancel subscriptions in State.dispose.
//
// SEE FIXED IMPLEMENTATION:
// lib/features/memory_lab/examples/fixed/undisposed_controllers_fixed.dart

class UndisposedControllersBroken extends StatefulWidget {
  const UndisposedControllersBroken({super.key, required this.controller});
  final LabDemoController controller;

  @override
  State<UndisposedControllersBroken> createState() =>
      _UndisposedControllersBrokenState();
}

class _UndisposedControllersBrokenState
    extends State<UndisposedControllersBroken> {
  final List<_LeakyHost> _hosts = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  void _onController() {
    if (!widget.controller.isRunning) return;
    // Simulate repeatedly opening a screen that leaks.
    for (var i = 0; i < 5; i++) {
      final host = _LeakyHost();
      host.start();
      _hosts.add(host);
      // "Close" without disposing — intentional leak.
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
        note: 'RSS growth ≠ proven leak; use DevTools retaining paths',
      ),
    ]);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    // Intentionally do NOT dispose hosts — demonstrates the bug.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MemoryDemoFrame(
      broken: true,
      message:
          'Opened ${_hosts.length} leaky hosts without dispose/cancel. '
          'Press Start repeatedly.',
      child: ListView.builder(
        itemCount: _hosts.length,
        itemBuilder: (_, i) => ListTile(
          dense: true,
          title: Text('Leaky host #$i'),
          subtitle: Text(_hosts[i].lastValue),
        ),
      ),
    );
  }
}

class _LeakyHost {
  late final TextEditingController text;
  late final StreamController<String> stream;
  StreamSubscription<String>? sub;
  String lastValue = '';

  void start() {
    text = TextEditingController(text: 'leak');
    lifecycleCounters.recordControllerCreated();
    stream = StreamController.broadcast();
    sub = stream.stream.listen((v) => lastValue = v);
    lifecycleCounters.recordSubscriptionCreated();
    stream.add('tick-${DateTime.now().millisecondsSinceEpoch}');
  }
}

class _MemoryDemoFrame extends StatelessWidget {
  const _MemoryDemoFrame({
    required this.broken,
    required this.message,
    required this.child,
  });

  final bool broken;
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = broken ? PerfKitColors.broken : PerfKitColors.fixed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Text(message, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(child: child),
      ],
    );
  }
}
