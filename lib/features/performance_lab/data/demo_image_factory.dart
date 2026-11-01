import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Generates deterministic PNG-like raw RGBA bitmaps for image demos.
/// Avoids network dependencies so demos work offline.
class DemoImageFactory {
  DemoImageFactory._();

  static final Map<String, Uint8List> _pngCache = {};

  static Future<Uint8List> png({
    required int width,
    required int height,
    int seed = 0,
  }) async {
    final key = '$width=${height}x$seed';
    final cached = _pngCache[key];
    if (cached != null) return cached;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint();

    for (var y = 0; y < height; y += 8) {
      for (var x = 0; x < width; x += 8) {
        final v = (x + y + seed * 17) % 255;
        paint.color = ui.Color.fromARGB(
          255,
          (v * 3) % 255,
          (v * 7 + seed) % 255,
          (v * 11) % 255,
        );
        canvas.drawRect(
          ui.Rect.fromLTWH(x.toDouble(), y.toDouble(), 8, 8),
          paint,
        );
      }
    }

    paint.color = const ui.Color(0xFFFFFFFF);
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(fontSize: (width / 12).clamp(10, 48).toDouble()),
          )
          ..pushStyle(ui.TextStyle(color: const ui.Color(0xFFFFFFFF)))
          ..addText('${width}x$height');
    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: width.toDouble()));
    canvas.drawParagraph(paragraph, const ui.Offset(12, 12));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final png = bytes!.buffer.asUint8List();
    _pngCache[key] = png;
    return png;
  }

  static void clearCache() {
    _pngCache.clear();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
