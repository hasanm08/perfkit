import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/diagnostics/rebuild_counter.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';

// ❌ PERFORMANCE PROBLEM:
// A frequently updating ticker lives at the top of a large widget tree.
// Every tick calls setState on the parent, rebuilding expensive siblings
// that do not depend on the ticking value.
//
// WHY IT IS A PROBLEM:
// Unrelated widgets (heavy static panels, lists of cards) rebuild every
// frame-interval tick even though their inputs are unchanged. Rebuilds
// themselves are not inherently evil — the waste is repeating expensive
// work that produces the same UI.
//
// HOW TO FIX:
// Move the ticking state closer to the widgets that need it, extract
// const/stable subtrees, or use ValueListenableBuilder / selectors so
// only dependents rebuild.
//
// SEE FIXED IMPLEMENTATION:
// lib/features/performance_lab/examples/fixed/unnecessary_rebuilds_fixed.dart

class UnnecessaryRebuildsBroken extends StatefulWidget {
  const UnnecessaryRebuildsBroken({
    super.key,
    required this.controller,
    required this.rebuildCounter,
  });

  final LabDemoController controller;
  final RebuildCounter rebuildCounter;

  @override
  State<UnnecessaryRebuildsBroken> createState() =>
      _UnnecessaryRebuildsBrokenState();
}

class _UnnecessaryRebuildsBrokenState extends State<UnnecessaryRebuildsBroken> {
  int _ticks = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  void _onController() {
    if (widget.controller.isRunning) {
      _timer ??= Timer.periodic(const Duration(milliseconds: 100), (_) {
        setState(() => _ticks++);
        _publish();
      });
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _publish() {
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Ticks value',
        value: '$_ticks',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'HeavyPanel rebuilds',
        value: '${widget.rebuildCounter.countFor('heavy')}',
        source: MetricSource.counter,
        note: 'Educational counter — not DevTools',
      ),
      MetricSnapshot(
        label: 'TickerLabel rebuilds',
        value: '${widget.rebuildCounter.countFor('ticker')}',
        source: MetricSource.counter,
      ),
    ]);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TickerLabel(ticks: _ticks, counter: widget.rebuildCounter),
          const SizedBox(height: 12),
          Expanded(child: _HeavyStaticPanel(counter: widget.rebuildCounter)),
        ],
      ),
    );
  }
}

class _TickerLabel extends StatelessWidget {
  const _TickerLabel({required this.ticks, required this.counter});
  final int ticks;
  final RebuildCounter counter;

  @override
  Widget build(BuildContext context) {
    counter.increment('ticker');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PerfKitColors.broken.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PerfKitColors.broken),
      ),
      child: Text(
        'Ticker: $ticks  (parent setState drives entire tree)',
        style: const TextStyle(fontFamily: 'monospace'),
      ),
    );
  }
}

class _HeavyStaticPanel extends StatelessWidget {
  const _HeavyStaticPanel({required this.counter});
  final RebuildCounter counter;

  @override
  Widget build(BuildContext context) {
    counter.increment('heavy');
    // Simulated expensive subtree — many children rebuilt each tick.
    return ListView.builder(
      itemCount: 40,
      itemBuilder: (context, i) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: PerfKitColors.surfaceElevated,
              child: Text('$i'),
            ),
            title: Text('Static row $i — should not rebuild each tick'),
            subtitle: Text(
              'hash=${Object.hash(i, 'static').toRadixString(16)}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        );
      },
    );
  }
}
