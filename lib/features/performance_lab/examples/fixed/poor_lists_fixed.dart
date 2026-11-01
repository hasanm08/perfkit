import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';

// ✅ OPTIMIZATION:
// ListView.builder lazily builds only visible (plus cache extent) items.
// Stable keys preserve identity; itemExtent enables cheaper layout.
//
// WHY IT WORKS:
// Cost scales with viewport size, not total collection size.
//
// PRODUCTION NOTE:
// itemExtent is valid only when all items share a fixed extent.

class PoorListsFixed extends StatefulWidget {
  const PoorListsFixed({
    super.key,
    required this.controller,
    required this.datasetSize,
  });

  final LabDemoController controller;
  final int datasetSize;

  @override
  State<PoorListsFixed> createState() => _PoorListsFixedState();
}

class _PoorListsFixedState extends State<PoorListsFixed> {
  int _built = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sync);
  }

  void _sync() {
    if (widget.controller.isRunning) {
      setState(() => _built = 0);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.controller.setMetrics([
        MetricSnapshot(
          label: 'Builders invoked',
          value: '$_built',
          source: MetricSource.counter,
          note: 'Educational — viewport-driven',
        ),
        MetricSnapshot(
          label: 'Dataset size',
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
            color: PerfKitColors.fixed.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PerfKitColors.fixed),
          ),
          child: Text(
            'ListView.builder + itemExtent for ${widget.datasetSize} items',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.datasetSize,
            itemExtent: 64,
            itemBuilder: (context, i) {
              _built++;
              final label = 'Row $i • ${i.toRadixString(16).padLeft(4, '0')}';
              return Container(
                key: ValueKey(i),
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
                      backgroundColor: PerfKitColors.fixed.withValues(
                        alpha: 0.2,
                      ),
                      child: Text(
                        '${i % 99}',
                        style: const TextStyle(fontSize: 10),
                      ),
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
            },
          ),
        ),
      ],
    );
  }
}
