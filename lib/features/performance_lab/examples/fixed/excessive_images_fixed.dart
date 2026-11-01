import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../app/theme/colors.dart';
import '../../../../core/models/metric_snapshot.dart';
import '../../../../core/widgets/lab_demo_controller.dart';
import '../../data/demo_image_factory.dart';

// ✅ OPTIMIZATION:
// Images are decoded at a size appropriate for the display tile via
// cacheWidth/cacheHeight (device-pixel aware).
//
// WHY IT WORKS:
// Decode and cache cost track display needs, not source megapixels.
//
// PRODUCTION NOTE:
// Prefer correctly sized assets in production; cacheWidth is a runtime aid.

class ExcessiveImagesFixed extends StatefulWidget {
  const ExcessiveImagesFixed({
    super.key,
    required this.controller,
    required this.imageResolution,
  });

  final LabDemoController controller;
  final int imageResolution;

  @override
  State<ExcessiveImagesFixed> createState() => _ExcessiveImagesFixedState();
}

class _ExcessiveImagesFixedState extends State<ExcessiveImagesFixed> {
  Uint8List? _bytes;
  bool _loading = true;

  bool _loadScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    // First load is scheduled after this frame so setState is not called
    // while the lab scaffold is still building.
    _scheduleLoad();
  }

  @override
  void didUpdateWidget(covariant ExcessiveImagesFixed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageResolution != widget.imageResolution) {
      _scheduleLoad();
    }
  }

  void _scheduleLoad() {
    if (_loadScheduled) return;
    _loadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduled = false;
      if (!mounted) return;
      _load();
    });
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
    final dpr = View.of(context).devicePixelRatio;
    final cachePx = (72 * dpr).round();
    widget.controller.setMetrics([
      MetricSnapshot(
        label: 'Source size',
        value: '${widget.imageResolution}²',
        source: MetricSource.counter,
      ),
      MetricSnapshot(
        label: 'cacheWidth',
        value: '$cachePx',
        source: MetricSource.counter,
        note: 'Matched to ~72 logical px tile',
      ),
      MetricSnapshot(
        label: 'PNG generate',
        value: '${sw.elapsedMilliseconds}',
        unit: 'ms',
        source: MetricSource.actual,
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
          child: Text(
            'Same source, decoded with cacheWidth/Height=$cachePx',
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
                  cacheWidth: cachePx,
                  cacheHeight: cachePx,
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
