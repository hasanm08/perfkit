import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';

// ❌ PERFORMANCE PROBLEM:
// A large collection is built eagerly as individual widgets inside a
// Column wrapped by SingleChildScrollView. Every item pays layout cost
// up front, even off-screen items.
//
// WHY IT IS A PROBLEM:
// Eager construction scales with N, not with viewport size. Scrolling
// and first paint become expensive for large datasets.
//
// HOW TO FIX:
// Use ListView.builder (or slivers), stable keys when identity matters,
// avoid shrinkWrap nested scrollables, and keep item builders cheap.
//
// SEE FIXED IMPLEMENTATION:
// lib/features/performance_lab/examples/fixed/poor_lists_fixed.dart

class PoorListsBroken extends StatefulWidget {
  const PoorListsBroken({
    super.key,
    required this.controller,
    required this.datasetSize,
  });

  final LabDemoController controller;
  final int datasetSize;

  @override
  State<PoorListsBroken> createState() => _PoorListsBrokenState();
}

class _PoorListsBrokenState extends State<PoorListsBroken> {
  final _scroll = ScrollController();
  Duration? _buildCost;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sync);
  }

  void _sync() {
    if (widget.controller.isRunning) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = Stopwatch()..start();
    // Eagerly construct ALL children.
    final children = List<Widget>.generate(widget.datasetSize, (i) {
      // Extra work per item to make the problem observable.
      final label = 'Row $i • ${i.toRadixString(16).padLeft(4, '0')}';
      return Container(
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: PerfKitColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PerfKitColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: PerfKitColors.broken.withValues(alpha: 0.2),
              child: Text('${i % 99}', style: const TextStyle(fontSize: 10)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            Text(
              '${(i * 37) % 1000}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
      );
    });
    sw.stop();
    _buildCost = sw.elapsed;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.controller.setMetrics([
        MetricSnapshot(
          label: 'Eager build',
          value: '${_buildCost?.inMilliseconds ?? 0}',
          unit: 'ms',
          source: MetricSource.actual,
          note: 'Stopwatch constructing Column children',
        ),
        MetricSnapshot(
          label: 'Item widgets',
          value: '${widget.datasetSize}',
          source: MetricSource.counter,
        ),
      ]);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: PerfKitColors.broken.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PerfKitColors.broken),
          ),
          child: Text(
            'Eager Column of ${widget.datasetSize} children in SingleChildScrollView',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}
