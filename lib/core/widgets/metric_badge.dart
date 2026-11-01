import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../models/metric_snapshot.dart';

class MetricBadge extends StatelessWidget {
  const MetricBadge({super.key, required this.metric});

  final MetricSnapshot metric;

  Color get _sourceColor => switch (metric.source) {
    MetricSource.actual => PerfKitColors.accent,
    MetricSource.counter => PerfKitColors.warning,
    MetricSource.simulated => PerfKitColors.secondaryText,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: PerfKitColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PerfKitColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _sourceColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  metric.sourceLabel.toUpperCase(),
                  style: TextStyle(
                    color: _sourceColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                metric.label,
                style: const TextStyle(
                  color: PerfKitColors.secondaryText,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            metric.unit.isEmpty
                ? metric.value
                : '${metric.value} ${metric.unit}',
            style: const TextStyle(
              color: PerfKitColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
          if (metric.note != null) ...[
            const SizedBox(height: 4),
            Text(
              metric.note!,
              style: const TextStyle(
                color: PerfKitColors.secondaryText,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
