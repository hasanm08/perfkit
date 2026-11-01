import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/diagnostics/frame_timing_monitor.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';

// ✅ OPTIMIZATION:
// Fewer primitives, no Opacity/ClipRRect saveLayer, RepaintBoundary around
// the animated region, and shouldRepaint only when animation value changes.
//
// WHY IT WORKS:
// Raster work drops because we avoid unnecessary layers and overdraw.
//
// PRODUCTION NOTE:
// Profile before introducing RepaintBoundary — extra layers have cost too.

class ExpensivePaintFixed extends StatefulWidget {
  const ExpensivePaintFixed({
    super.key,
    required this.controller,
    required this.frameMonitor,
  });

  final LabDemoController controller;
  final FrameTimingMonitor frameMonitor;

  @override
  State<ExpensivePaintFixed> createState() => _ExpensivePaintFixedState();
}

class _ExpensivePaintFixedState extends State<ExpensivePaintFixed>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  int _paintCalls = 0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    widget.controller.addListener(_sync);
    widget.frameMonitor.addListener(_publish);
  }

  void _sync() {
    if (widget.controller.isRunning) {
      widget.frameMonitor.start();
      _anim.repeat();
    } else {
      _anim.stop();
      widget.frameMonitor.stop();
    }
  }

  void _publish() {
    final build = widget.frameMonitor.averageBuildMicros;
    final raster = widget.frameMonitor.averageRasterMicros;
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Paint calls',
        value: '$_paintCalls',
        source: MetricSource.counter,
      ),
      if (build != null)
        MetricSnapshot(
          label: 'Avg build',
          value: (build / 1000).toStringAsFixed(2),
          unit: 'ms',
          source: MetricSource.actual,
          note: 'FrameTiming — debug ≠ release',
        ),
      if (raster != null)
        MetricSnapshot(
          label: 'Avg raster',
          value: (raster / 1000).toStringAsFixed(2),
          unit: 'ms',
          source: MetricSource.actual,
        ),
    ]);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    widget.frameMonitor.removeListener(_publish);
    _anim.dispose();
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
          child: const Text(
            'RepaintBoundary + cheap painter (no Opacity/Clip saveLayer)',
            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        Expanded(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LightPainter(
                    t: _anim.value,
                    onPaint: () {
                      _paintCalls++;
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _publish();
                      });
                    },
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _LightPainter extends CustomPainter {
  _LightPainter({required this.t, required this.onPaint});

  final double t;
  final VoidCallback onPaint;

  @override
  void paint(Canvas canvas, Size size) {
    onPaint();
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF14B8A6);
    final cx = size.width / 2;
    final cy = size.height / 2;
    for (var i = 0; i < 24; i++) {
      final r = 20.0 + i * 12 + 8 * sin(t * pi * 2 + i / 3);
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LightPainter oldDelegate) => oldDelegate.t != t;
}
