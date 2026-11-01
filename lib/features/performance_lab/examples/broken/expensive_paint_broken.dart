import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/diagnostics/frame_timing_monitor.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';

// ❌ PERFORMANCE PROBLEM:
// Full-screen CustomPainter redraws dense geometry every frame, wrapped in
// Opacity and ClipRRect that force saveLayer / expensive compositing.
// shouldRepaint always returns true.
//
// WHY IT IS A PROBLEM:
// Unnecessary paint and compositing work inflate raster time and can
// create avoidable layers.
//
// HOW TO FIX:
// Reduce paint complexity, use RepaintBoundary selectively, implement
// cheap shouldRepaint, avoid unjustified opacity/clip saveLayers.
//
// SEE FIXED IMPLEMENTATION:
// lib/features/performance_lab/examples/fixed/expensive_paint_fixed.dart

class ExpensivePaintBroken extends StatefulWidget {
  const ExpensivePaintBroken({
    super.key,
    required this.controller,
    required this.frameMonitor,
  });

  final LabDemoController controller;
  final FrameTimingMonitor frameMonitor;

  @override
  State<ExpensivePaintBroken> createState() => _ExpensivePaintBrokenState();
}

class _ExpensivePaintBrokenState extends State<ExpensivePaintBroken>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  int _paintCalls = 0;

  @override
  void initState() {
    super.initState();
    _anim =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..addListener(() {
            if (widget.controller.isRunning) setState(() {});
          });
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
            color: PerfKitColors.broken.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PerfKitColors.broken),
          ),
          child: const Text(
            'Opacity + ClipRRect + dense CustomPainter every frame',
            style: TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        Expanded(
          child: Opacity(
            opacity: 0.92,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomPaint(
                painter: _HeavyPainter(
                  t: _anim.value,
                  onPaint: () {
                    _paintCalls++;
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _publish();
                    });
                  },
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeavyPainter extends CustomPainter {
  _HeavyPainter({required this.t, required this.onPaint});

  final double t;
  final VoidCallback onPaint;

  @override
  void paint(Canvas canvas, Size size) {
    onPaint();
    final paint = Paint()..style = PaintingStyle.stroke;
    final rng = Random(0);
    for (var i = 0; i < 400; i++) {
      paint
        ..color = Color.fromARGB(
          180,
          rng.nextInt(255),
          rng.nextInt(255),
          rng.nextInt(255),
        )
        ..strokeWidth = 1 + (i % 4).toDouble()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final r = 10.0 + (i % 40) + 20 * sin(t * pi * 2 + i);
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeavyPainter oldDelegate) => true;
}
