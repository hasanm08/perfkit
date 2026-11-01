import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';
import '../../../performance_lab/data/demo_image_factory.dart';

// ✅ OPTIMIZATION:
// Decode with cacheWidth for thumbnails, keep default ImageCache limits,
// and clear strong references when leaving the demo.
//
// WHY IT WORKS:
// Display-sized decodes + bounded cache + released refs limit retention.
//
// PRODUCTION NOTE:
// Do not call imageCache.clear() on every navigation — it thrashs UX.

class ImageCacheFixed extends StatefulWidget {
  const ImageCacheFixed({super.key, required this.controller});
  final LabDemoController controller;

  @override
  State<ImageCacheFixed> createState() => _ImageCacheFixedState();
}

class _ImageCacheFixedState extends State<ImageCacheFixed> {
  Uint8List? _shared;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    // Restore sensible defaults.
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSize = 100;
    cache.maximumSizeBytes = 100 << 20;
  }

  Future<void> _onController() async {
    if (!widget.controller.isRunning) return;
    _shared = await DemoImageFactory.png(width: 800, height: 800, seed: 1);
    if (!mounted) return;
    final cache = PaintingBinding.instance.imageCache;
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Shared source',
        value: '1',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'Decode target',
        value: 'cacheWidth=96',
        source: MetricSource.counter,
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
    _shared = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cachePx = (72 * dpr).round();
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
            'One source buffer, thumbnail decode, default cache limits',
            style: TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: _shared == null
              ? const Center(
                  child: Text(
                    'Press Start',
                    style: TextStyle(color: PerfKitColors.secondaryText),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: 16,
                  itemBuilder: (_, i) => Image.memory(
                    _shared!,
                    fit: BoxFit.cover,
                    cacheWidth: cachePx,
                    cacheHeight: cachePx,
                  ),
                ),
        ),
      ],
    );
  }
}
