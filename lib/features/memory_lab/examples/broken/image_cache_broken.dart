import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';
import '../../../performance_lab/data/demo_image_factory.dart';

// ❌ MEMORY PROBLEM:
// Many large images are decoded and retained in an application-level list
// while ImageCache maximums are raised unboundedly.
//
// WHY IT IS A PROBLEM:
// Unbounded caches and strong references keep decoded images alive far
// beyond what the UI needs.
//
// HOW TO FIX:
// Use thumbnails, keep ImageCache limits sensible, drop strong refs when
// screens dispose. Avoid blindly clearing the global cache (hurts UX).
//
// SEE FIXED IMPLEMENTATION:
// lib/features/memory_lab/examples/fixed/image_cache_fixed.dart

class ImageCacheBroken extends StatefulWidget {
  const ImageCacheBroken({super.key, required this.controller});
  final LabDemoController controller;

  @override
  State<ImageCacheBroken> createState() => _ImageCacheBrokenState();
}

class _ImageCacheBrokenState extends State<ImageCacheBroken> {
  final List<Uint8List> _retained = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  Future<void> _onController() async {
    if (!widget.controller.isRunning) return;
    // Raise cache ceiling aggressively.
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = 1000;
    cache.maximumSizeBytes = 200 << 20;

    for (var i = 0; i < 8; i++) {
      final bytes = await DemoImageFactory.png(
        width: 800,
        height: 800,
        seed: i + _retained.length,
      );
      _retained.add(bytes);
    }
    if (!mounted) return;
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Retained PNGs',
        value: '${_retained.length}',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'ImageCache count',
        value: '${cache.currentSize}',
        source: MetricSource.actual,
        note: 'Flutter ImageCache — not a DevTools heap snapshot',
      ),
      MetricSnapshot(
        label: 'ImageCache bytes',
        value: '${(cache.currentSizeBytes / (1 << 20)).toStringAsFixed(2)} MB',
        source: MetricSource.actual,
      ),
    ]);
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
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
          child: Text(
            'Holding ${_retained.length} full-size PNG buffers + inflated ImageCache',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: _retained.length,
            itemBuilder: (_, i) =>
                Image.memory(_retained[i], fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}
