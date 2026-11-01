import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/diagnostics/rebuild_counter.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';

// ✅ OPTIMIZATION:
// Ticking state is isolated in a ValueNotifier. Only the ticker label
// rebuilds via ValueListenableBuilder. The heavy panel is const and stable.
//
// WHY IT WORKS:
// Unrelated widgets are no longer coupled to the ticking value. Rebuild
// cost is limited to the small dependent subtree.
//
// PRODUCTION NOTE:
// Measure rebuild cost before adding state-management complexity.
// Not every rebuild needs to be eliminated — eliminate expensive work.

class UnnecessaryRebuildsFixed extends StatefulWidget {
  const UnnecessaryRebuildsFixed({
    super.key,
    required this.controller,
    required this.rebuildCounter,
  });

  final LabDemoController controller;
  final RebuildCounter rebuildCounter;

  @override
  State<UnnecessaryRebuildsFixed> createState() =>
      _UnnecessaryRebuildsFixedState();
}

class _UnnecessaryRebuildsFixedState extends State<UnnecessaryRebuildsFixed> {
  final ValueNotifier<int> _ticks = ValueNotifier(0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    _ticks.addListener(_publish);
  }

  void _onController() {
    if (widget.controller.isRunning) {
      _timer ??= Timer.periodic(const Duration(milliseconds: 100), (_) {
        _ticks.value++;
      });
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _publish() {
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Ticker value',
        value: '${_ticks.value}',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'HeavyPanel rebuilds',
        value: '${widget.rebuildCounter.countFor('heavy')}',
        source: MetricSource.counter,
        note: 'Should stay near 1',
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
    _ticks.removeListener(_publish);
    _timer?.cancel();
    _ticks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: _ticks,
            builder: (context, value, _) {
              widget.rebuildCounter.increment('ticker');
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PerfKitColors.fixed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PerfKitColors.fixed),
                ),
                child: Text(
                  'Ticker: $value  (localized via ValueListenableBuilder)',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Expanded(child: _HeavyStaticPanel(counter: widget.rebuildCounter)),
        ],
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
            title: Text('Static row $i — rebuilt only when parent rebuilds'),
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
