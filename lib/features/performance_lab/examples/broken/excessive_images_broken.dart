import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';
import '../../data/demo_image_factory.dart';

// ❌ PERFORMANCE PROBLEM:
// High-resolution images are decoded at full size and displayed in tiny
// tiles. Decoding cost and image cache pressure scale with source pixels,
// not display size.
//
// WHY IT IS A PROBLEM:
// Unnecessary decode work and RAM usage hurt scroll performance and
// increase memory pressure in galleries.
//
// HOW TO FIX:
// Provide appropriately sized assets, use cacheWidth/cacheHeight, and
// prefer thumbnails in lists.
//
// SEE FIXED IMPLEMENTATION:
// lib/features/performance_lab/examples/fixed/excessive_images_fixed.dart

class ExcessiveImagesBroken extends StatefulWidget {
  const ExcessiveImagesBroken({
    super.key,
    required this.controller,
    required this.imageResolution,
  });

  final LabDemoController controller;
  final int imageResolution;

  @override
  State<ExcessiveImagesBroken> createState() => _ExcessiveImagesBrokenState();
}

class _ExcessiveImagesBrokenState extends State<ExcessiveImagesBroken> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    _load();
  }

  @override
  void didUpdateWidget(covariant ExcessiveImagesBroken oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageResolution != widget.imageResolution) {
      _load();
    }
  }

  void _onController() {
    if (widget.controller.isRunning) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final sw = Stopwatch()..start();
    final bytes = await DemoImageFactory.png(
      width: widget.imageResolution,
      height: widget.imageResolution,
      seed: 7,
    );
    sw.stop();
    if (!mounted) return;
    setState(() {
      _bytes = bytes;
      _loading = false;
    });
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Source decode size',
        value: '${widget.imageResolution}²',
        source: MetricSource.counter,
        note: 'Displayed in ~72px tiles',
      ),
      MetricSnapshot(
        label: 'PNG generate',
        value: '${sw.elapsedMilliseconds}',
        unit: 'ms',
        source: MetricSource.actual,
      ),
      MetricSnapshot(
        label: 'cacheWidth',
        value: 'none',
        source: MetricSource.counter,
      ),
    ]);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _bytes == null) {
      return const Center(child: CircularProgressIndicator());
    }
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
          child: Text(
            'Decoding ${widget.imageResolution}x${widget.imageResolution} into 72px tiles (no cacheWidth)',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 24,
            itemBuilder: (_, i) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  _bytes!,
                  fit: BoxFit.cover,
                  // Intentionally omit cacheWidth/cacheHeight.
                  gaplessPlayback: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
